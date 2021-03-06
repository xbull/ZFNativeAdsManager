//
//  ZFNativeAdsManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFNativeAdsManager.h"
#import "ZFNativeAdsMediator+Facebook.h"
#import "ZFNativeAdsMediator+Mobvista.h"
#import "ZFNativeAdsMediator+MVAppWall.h"
#import <objc/runtime.h>
#import "NSMutableDictionary+DPExtension.h"

#define DPErrorTolerate 3

static const NSString *DPNativeAdsKey;

@interface ZFNativeAdsManager () <ZFNativeAdsDelegate>

@property (nonatomic, strong) NSMutableArray<NSNumber *> *priorityIndicator;

@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *infoArray;
@property (nonatomic, strong) NSMutableDictionary *nativeAdsPool;
@property (nonatomic, strong) NSMutableDictionary *capacityDic;
@property (nonatomic, strong) NSMutableDictionary *loadImageOptionDic;
@property (nonatomic, strong) NSMutableDictionary *errorInfoDic;

@property (nonatomic, strong) NSMutableDictionary *reformedAdFetchBlockDictionary;

@end

@implementation ZFNativeAdsManager

+ (instancetype)sharedInstance {
    static ZFNativeAdsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZFNativeAdsManager alloc] init];
        instance.mobvistaRefine = NO;
    });
    return instance;
}

- (void)configureAppId:(NSString *)appId apiKey:(NSString *)apiKey platform:(ZFNativeAdsPlatform)platform {
    
    switch (platform) {
        case ZFNativeAdsPlatformFacebook: {
        }
            break;
            
        case ZFNativeAdsPlatformMobvista: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_configureMobvistaAppId:appId apiKey:apiKey];
        }
            break;
            
        default:
            NSLog(@"【ZFNativeAdsManager】should never reach here!");
            break;
    }
}

- (void)configurePlacementInfo:(NSDictionary *)placementInfo platform:(ZFNativeAdsPlatform)platform {
    
    NSMutableDictionary *platformInfo = [NSMutableDictionary dictionaryWithDictionary:placementInfo];
    [self.infoArray replaceObjectAtIndex:platform withObject:platformInfo];
    
    for (NSString *key in placementInfo) {
        if (![self.nativeAdsPool objectForKey:key]) {
            [self.capacityDic safeSetObject:@(1) forKey:key];
            NSMutableArray *placementAdPool = [NSMutableArray arrayWithCapacity:ZFNativeAdsPlatformCount * [[self.capacityDic objectForKey:key] integerValue]];
            [self.nativeAdsPool safeSetObject:placementAdPool forKey:key];
        }
    }
    
    switch (platform) {
        case ZFNativeAdsPlatformFacebook: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setFacebookDelegate:self];
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_configureFacebookPlacementInfo:placementInfo];
        }
            break;
            
        case ZFNativeAdsPlatformMobvista: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setMobvistaDelegate:self];
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_configureMobvistaWithPlacementInfo:placementInfo];
        }
            break;
            
        default:
            NSLog(@"【ZFNativeAdsManager】should never reach here!");
            break;
    }
}

- (void)setPriority:(NSArray<NSNumber *> *)priorityArray {
    
    if (priorityArray.count > ZFNativeAdsPlatformCount) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [priorityArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.priorityIndicator replaceObjectAtIndex:obj.unsignedIntegerValue withObject:[NSNumber numberWithUnsignedInteger:idx]];
    }];
    
    NSLog(@"【ZFNativeAdsManager】 indicator:%@", self.priorityIndicator);
}

- (void)setCapacity:(NSUInteger)capacity forPlacement:(NSString *)placementKey {
    [self.capacityDic safeSetObject:@(capacity) forKey:placementKey];
}

- (void)preloadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption {
    
    [self clearErrorForPlace:placementKey];
    [self loadNativeAdsIfNecessary:placementKey loadImageOption:loadImageOption preload:YES];
    [self.loadImageOptionDic safeSetObject:@(loadImageOption) forKey:placementKey];
}

- (void)preloadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption capacity:(NSUInteger)capacity {
    
    [self clearErrorForPlace:placementKey];
    [self setCapacity:capacity forPlacement:placementKey];
    [self loadNativeAdsIfNecessary:placementKey loadImageOption:loadImageOption preload:YES];
    [self.loadImageOptionDic safeSetObject:@(loadImageOption) forKey:placementKey];
}

- (ZFReformedNativeAd *)fetchPreloadAdForPlacement:(NSString *)placementKey {
    
    [self clearErrorForPlace:placementKey];
    NSMutableArray<ZFReformedNativeAd *> *placementAdPool = [self.nativeAdsPool objectForKey:placementKey];
    if (placementAdPool && placementAdPool.count > 0) {
        [placementAdPool sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            ZFReformedNativeAd *ad1 = obj1;
            ZFReformedNativeAd *ad2 = obj2;
            return [[self.priorityIndicator objectAtIndex:[ad1 platform]] compare:[self.priorityIndicator objectAtIndex:[ad2 platform]]];
        }];
        NSLog(@"【ZFNativeAdsManager】native ad sorted pool for this placement:%@", placementAdPool);
        
        ZFReformedNativeAd *nativeAd = [placementAdPool firstObject];
        [placementAdPool removeObject:nativeAd];
        
        [self fillUpAdPoolIfNecessary:placementKey platform:nativeAd.platform];
        
        return nativeAd;
    }
    [self fillUpAdPoolIfNecessary:placementKey];

    return nil;
}

- (NSArray<ZFReformedNativeAd *> *)fetchPreloadAdForPlacement:(NSString *)placementKey count:(NSUInteger)count {
    
    [self clearErrorForPlace:placementKey];
    NSMutableArray<ZFReformedNativeAd *> *placementAdPool = [self.nativeAdsPool objectForKey:placementKey];
    if (placementAdPool && placementAdPool.count > 0) {
        [placementAdPool sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            ZFReformedNativeAd *ad1 = obj1;
            ZFReformedNativeAd *ad2 = obj2;
            return [[self.priorityIndicator objectAtIndex:[ad1 platform]] compare:[self.priorityIndicator objectAtIndex:[ad2 platform]]];
        }];
        NSLog(@"【ZFNativeAdsManager】native ad sorted pool for this placement:%@", placementAdPool);
        
        NSUInteger fetchedCount = (count < placementAdPool.count) ? count : placementAdPool.count;
        NSMutableArray *reformedNativeAds = [NSMutableArray arrayWithCapacity:fetchedCount];
        
        NSMutableArray<ZFReformedNativeAd *> *newPlacementAdPool = [NSMutableArray arrayWithArray:placementAdPool];
        
        for (ZFReformedNativeAd *nativeAd in placementAdPool) {
            BOOL appear = NO;
            for (ZFReformedNativeAd *uniqueAd in reformedNativeAds) {
                if ([uniqueAd.title isEqualToString:nativeAd.title]) {
                    appear = YES;
                    break ;
                }
            }
            if (!appear) {
                [reformedNativeAds addObject:nativeAd];
                [newPlacementAdPool removeObject:nativeAd];
            }
            if (reformedNativeAds.count >= fetchedCount) {
                break ;
            }
        }
        
        [self.nativeAdsPool safeSetObject:newPlacementAdPool forKey:placementKey];
        
        [self fillUpAdPoolIfNecessary:placementKey];
        
        return [reformedNativeAds copy];
    }
    [self fillUpAdPoolIfNecessary:placementKey];
    return [NSArray array];
}

- (void)fetchAdForPlacement:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption fetchBlock:(ZFReformedAdFetchBlock)fetchblock {
    
    NSMutableArray<ZFReformedNativeAd *> *placementAdPool = [self.nativeAdsPool objectForKey:placementKey];
    if (placementAdPool && placementAdPool.count > 0) {
        [placementAdPool sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            ZFReformedNativeAd *ad1 = obj1;
            ZFReformedNativeAd *ad2 = obj2;
            return [[self.priorityIndicator objectAtIndex:[ad1 platform]] compare:[self.priorityIndicator objectAtIndex:[ad2 platform]]];
        }];
        NSLog(@"【ZFNativeAdsManager】native ad sorted pool for this placement:%@", placementAdPool);
        
        ZFReformedNativeAd *nativeAd = [placementAdPool objectAtIndex:0];
        [placementAdPool removeObjectAtIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            fetchblock(nativeAd);
        });
    } else {
        
        [self.reformedAdFetchBlockDictionary safeSetObject:fetchblock forKey:placementKey];
        
        [self loadNativeAdsIfNecessary:placementKey loadImageOption:loadImageOption preload:NO];
    }
    
}

- (void)registAdForInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view {
    
    switch (reformedAd.platform) {
        case ZFNativeAdsPlatformFacebook: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_registerFacebookAdInteraction:reformedAd view:view];
        }
            break;
            
        case ZFNativeAdsPlatformMobvista: {
            [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_registerMobvistaAdInteraction:reformedAd view:view];
        }
            break;
            
        default:
            NSLog(@"【ZFNativeAdsManager】should never reach here!");
            break;
    }
}

- (void)configureAppWallWithUnitId:(NSString *)unitId navigationController:(UINavigationController *)navigationController {
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_configureMVAppWallWithUnitId:unitId navigationController:navigationController];
}

- (void)preloadAppWall:(NSString *)appWallUnitId {
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_preloadMVAppWall:appWallUnitId];
}

- (void)showAppWall {
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_showMVAppWall];
}

- (UIView *)fetchAdChoiceView:(ZFReformedNativeAd *)reformedAd corner:(UIRectCorner)corner {
    
    if (reformedAd.platform == ZFNativeAdsPlatformFacebook) {
        return [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_fetchAdChoiceView:reformedAd corner:corner];
    }
    
    return nil;
}

#pragma mark - <ZFNativeAdsDelegate>
- (void)nativeAdDidLoad:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey {
    
    NSLog(@"【ZFNativeAdsManager】native ad did load from platform:%ld, placement:%@", (long)platform, placementKey);
    
    NSMutableOrderedSet *placementAdPool = [self.nativeAdsPool objectForKey:placementKey];
    NSUInteger beforeCount = placementAdPool.count;
    
    ZFReformedAdFetchBlock fetchBlock = [self.reformedAdFetchBlockDictionary objectForKey:placementKey];
    if (!beforeCount && fetchBlock) {
        NSLog(@"【ZFNativeAdsManager】native ad did load for placement:%@", placementKey);
        
        ZFReformedNativeAd *reformedAd = [self fetchAdFromPlatform:platform placement:placementKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            fetchBlock(reformedAd);
        });
        
        [self.reformedAdFetchBlockDictionary removeObjectForKey:placementKey];
    }else {
        [self saveAdToPoolOfPlace:placementKey platform:platform];
        
        [self fillUpAdPoolIfNecessary:placementKey platform:platform];
    }
    [self clearErrorForPlace:placementKey platform:platform];
}

- (void)nativeAdDidFail:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey error:(NSError *)error {
    [self recordErrorOfPlace:placementKey platform:platform];
    if (![self shouldStopLoadAtPlace:placementKey platform:platform]) {
        [self fillUpAdPoolIfNecessary:placementKey platform:platform];
    }
}

- (void)nativeAdDidClick:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:placementKey];
    }
}

#pragma mark - Private methods

- (void)loadNativeAdsIfNecessary:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption preload:(BOOL)preload {
    
    [self loadNativeAdsIfNecessary:placementKey loadImageOption:loadImageOption platform:ZFNativeAdsPlatformFacebook preload:preload];
    [self loadNativeAdsIfNecessary:placementKey loadImageOption:loadImageOption platform:ZFNativeAdsPlatformMobvista preload:preload];
}

- (void)loadNativeAdsIfNecessary:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption platform:(ZFNativeAdsPlatform)platform preload:(BOOL)preload {
    
    switch (platform) {
        case ZFNativeAdsPlatformFacebook:
            if ([[self.priorityIndicator objectAtIndex:ZFNativeAdsPlatformFacebook] unsignedIntegerValue] < ZFNativeAdsPlatformCount) {
                if (![self isFullInAdPoolOfPlace:placementKey platform:ZFNativeAdsPlatformFacebook]) {
                    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_loadFacebookNativeAds:placementKey loadImageOption:loadImageOption preload:preload];
                }
            }
            break;
        case ZFNativeAdsPlatformMobvista:
            if ([[self.priorityIndicator objectAtIndex:ZFNativeAdsPlatformMobvista] unsignedIntegerValue] < ZFNativeAdsPlatformCount) {
                if (![self isFullInAdPoolOfPlace:placementKey platform:ZFNativeAdsPlatformMobvista]) {
                    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_loadMobvistaNativeAds:placementKey loadImageOption:loadImageOption];
                }
            }
            break;
            
        default:
            break;
    }
    
}

- (ZFReformedNativeAd *)fetchAdFromPlatform:(ZFNativeAdsPlatform)platform placement:(NSString *)placementKey {
    
    NSLog(@"【ZFNativeAdsManager】fetch native ad from platform:%ld", (long)platform);
    
    switch (platform) {
        case ZFNativeAdsPlatformFacebook: {
            ZFReformedNativeAd *ad = [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_fetchFacebookNativeAd:placementKey];
            NSLog(@"【ZFNativeAdsManager】fetch reformed ad from Facebook:%@", ad);
            return ad;
        }
            break;
            
        case ZFNativeAdsPlatformMobvista: {
            ZFReformedNativeAd *ad = [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_fetchMobvistaNativeAd:placementKey];
            NSLog(@"【ZFNativeAdsManager】fetch reformed ad from Mobvista:%@", ad);
            return ad;
        }
            break;
            
        default: {
            NSLog(@"【ZFNativeAdsManager】should never reach here!");
            return nil;
        }
            break;
    }
}

- (void)setDebugLogEnable:(BOOL)enable {
    
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setFacebookDebugLogEnable:enable];
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setMobvistaDebugLogEnable:enable];
}

- (NSUInteger)countOfAd:(NSInteger)platform inPool:(NSMutableOrderedSet *)pool {
    __block NSUInteger count = 0;
    [pool enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZFReformedNativeAd *ad = obj;
        if ([ad platform] == platform) {
            count++;
        }
    }];
    return count;
}

- (void)fillUpAdPoolIfNecessary:(NSString *)placementKey {
    [self fillUpAdPoolIfNecessary:placementKey platform:ZFNativeAdsPlatformFacebook];
    [self fillUpAdPoolIfNecessary:placementKey platform:ZFNativeAdsPlatformMobvista];
}

- (void)fillUpAdPoolIfNecessary:(NSString *)placementKey platform:(ZFNativeAdsPlatform)platform {
    
    NSNumber *loadImageOption = [self.loadImageOptionDic objectForKey:placementKey];
    
    if (!loadImageOption) {
        loadImageOption = @(ZFNativeAdsLoadImageOptionNone);
    }
    [self loadNativeAdsIfNecessary:placementKey loadImageOption:loadImageOption.integerValue platform:platform preload:YES];
}

- (void)saveAdToPoolOfPlace:(NSString *)placementKey platform:(ZFNativeAdsPlatform)platform {
    
    if (![self isFullInAdPoolOfPlace:placementKey platform:platform]) {
        
        NSMutableOrderedSet *placementAdPool = [self.nativeAdsPool objectForKey:placementKey];
        ZFReformedNativeAd *reformedAd = [self fetchAdFromPlatform:platform placement:placementKey];
        
        if (reformedAd) {
            [placementAdPool addObject:reformedAd];
            [self.nativeAdsPool safeSetObject:placementAdPool forKey:placementKey];
        }
    }
}

- (BOOL)isFullInAdPoolOfPlace:(NSString *)placementKey platform:(ZFNativeAdsPlatform)platform {
    NSMutableOrderedSet *placementAdPool = [self.nativeAdsPool objectForKey:placementKey];
    NSUInteger adCount = [self countOfAd:platform inPool:placementAdPool];
    if (adCount < [[self.capacityDic objectForKey:placementKey] integerValue]) {
        return NO;
    }
    return YES;
}

- (void)recordErrorOfPlace:(NSString *)placementKey platform:(ZFNativeAdsPlatform)platform {
    if (![self.errorInfoDic objectForKey:placementKey]) {
        NSMutableDictionary *placeAdErrorDic = [NSMutableDictionary dictionary];
        [self.errorInfoDic safeSetObject:placeAdErrorDic forKey:placementKey];
    }
    NSMutableDictionary *placeAdErrorDic = [self.errorInfoDic objectForKey:placementKey];
    if (![placeAdErrorDic objectForKey:@(platform)]) {
        [placeAdErrorDic safeSetObject:@(0) forKey:@(platform)];
    }
    NSInteger count = [[placeAdErrorDic objectForKey:@(platform)] integerValue];
    [placeAdErrorDic safeSetObject:@(count + 1) forKey:@(platform)];
    [self.errorInfoDic safeSetObject:placeAdErrorDic forKey:placementKey];
}

- (void)clearErrorForPlace:(NSString *)placementKey {
    [self clearErrorForPlace:placementKey platform:ZFNativeAdsPlatformFacebook];
    [self clearErrorForPlace:placementKey platform:ZFNativeAdsPlatformMobvista];
}

- (void)clearErrorForPlace:(NSString *)placementKey platform:(ZFNativeAdsPlatform)platform {
    if (![self.errorInfoDic objectForKey:placementKey]) {
        NSMutableDictionary *placeAdErrorDic = [NSMutableDictionary dictionary];
        [self.errorInfoDic safeSetObject:placeAdErrorDic forKey:placementKey];
    }
    NSMutableDictionary *placeAdErrorDic = [self.errorInfoDic objectForKey:placementKey];
    [placeAdErrorDic safeSetObject:@(0) forKey:@(platform)];
}

- (BOOL)shouldStopLoadAtPlace:(NSString *)placementKey platform:(ZFNativeAdsPlatform)platform {
    if (![self.errorInfoDic objectForKey:placementKey]) {
        NSMutableDictionary *placeAdErrorDic = [NSMutableDictionary dictionary];
        [self.errorInfoDic safeSetObject:placeAdErrorDic forKey:placementKey];
        return NO;
    }
    NSMutableDictionary *placeAdErrorDic = [self.errorInfoDic objectForKey:placementKey];
    if (![placeAdErrorDic objectForKey:@(platform)]) {
        [placeAdErrorDic safeSetObject:@(0) forKey:@(platform)];
        return NO;
    }
    if ([[placeAdErrorDic objectForKey:@(platform)] integerValue] >= DPErrorTolerate) {
        return YES;
    }
    return NO;
}

#pragma mark - Setters
- (void)setMobvistaRefine:(BOOL)mobvistaRefine {
    _mobvistaRefine = mobvistaRefine;
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setMobvistaRefineMode:mobvistaRefine];
}

#pragma mark - Getters
- (NSMutableArray<NSNumber *> *)priorityIndicator {
    if (!_priorityIndicator) {
        _priorityIndicator = [NSMutableArray<NSNumber *> arrayWithCapacity:ZFNativeAdsPlatformCount];
        for (NSInteger i = 0; i < ZFNativeAdsPlatformCount; i++) {
            [_priorityIndicator addObject:@(ZFNativeAdsPlatformCount)];
        }
    }
    return _priorityIndicator;
}

- (NSMutableArray<NSMutableDictionary *> *)infoArray {
    if (!_infoArray) {
        _infoArray = [NSMutableArray<NSMutableDictionary *> arrayWithCapacity:ZFNativeAdsPlatformCount];
        for (int i = 0; i < ZFNativeAdsPlatformCount; i++) {
            
            NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionary];
            [_infoArray addObject:infoDictionary];
        }
    }
    return _infoArray;
}

- (NSMutableDictionary *)nativeAdsPool {
    if (!_nativeAdsPool) {
        _nativeAdsPool = [NSMutableDictionary dictionary];
    }
    return _nativeAdsPool;
}

- (NSMutableDictionary *)reformedAdFetchBlockDictionary {
    if (!_reformedAdFetchBlockDictionary) {
        _reformedAdFetchBlockDictionary = [NSMutableDictionary dictionary];
    }
    return _reformedAdFetchBlockDictionary;
}

- (NSMutableDictionary *)capacityDic {
    if (!_capacityDic) {
        _capacityDic = [NSMutableDictionary dictionary];
    }
    return _capacityDic;
}

- (NSMutableDictionary *)loadImageOptionDic {
    if (!_loadImageOptionDic) {
        _loadImageOptionDic = [NSMutableDictionary dictionary];
    }
    return _loadImageOptionDic;
}

- (NSMutableDictionary *)errorInfoDic {
    if (!_errorInfoDic) {
        _errorInfoDic = [NSMutableDictionary dictionary];
    }
    return _errorInfoDic;
}

@end
