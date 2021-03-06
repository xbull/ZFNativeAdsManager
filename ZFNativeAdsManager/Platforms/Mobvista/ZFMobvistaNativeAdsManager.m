//
//  ZFMobvistaNativeAdsManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFMobvistaNativeAdsManager.h"
#import <MVSDK/MVSDK.h>
#import <objc/runtime.h>
#import "ZFMobvistaNativeAdObserver.h"
#import <StoreKit/StoreKit.h>
#import "NSMutableDictionary+DPExtension.h"

#define MV_NATIVE_ADS_REQUEST_ONCE_COUNT        10
#define MV_NATIVE_ADS_POOL_REFILL_THRESHOLD     5

static const char MVReformAdKey;
static const char MVAdPlacementKey;
static const char MVReformAdErrorKey;

typedef NS_ENUM(NSUInteger, DPMobvistaStatus) {
    DPMobvistaStatusBusy = 0,
    DPMobvistaStatusFree,
    DPMobvistaStatusCount
};

@interface ZFMobvistaNativeAdsManager () <ZFMobvistaNativeAdObserverDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *placementInfo;

@property (nonatomic, strong) NSMutableDictionary *placementAdsManager;

@property (nonatomic, strong) NSMutableDictionary *loadImageIndicator;

@property (nonatomic, strong) NSMutableDictionary *reformedAdsCachePool;

@property (nonatomic, strong) NSMutableArray<ZFMobvistaNativeAdObserver *> *observerRetainArray;
@property (nonatomic, strong) NSMutableArray<MVCampaign *> *campaignRetainArray;

@property (nonatomic, assign) BOOL debugLogEnable;

@property (nonatomic, assign) BOOL refineMode;

@property (nonatomic, assign) DPMobvistaStatus taskStatus;

@property (nonatomic, assign) NSUInteger finishedTaskCount;

@property (nonatomic, assign) NSUInteger totalTaskCount;

@end

@implementation ZFMobvistaNativeAdsManager

+ (instancetype)sharedInstance {
    static ZFMobvistaNativeAdsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZFMobvistaNativeAdsManager alloc] init];
        instance.taskStatus = DPMobvistaStatusFree;
    });
    return instance;
}

#pragma mark - public methods
- (void)configureAppId:(NSString *)appId apiKey:(NSString *)apiKey {
    [[MVSDK sharedInstance] setAppID:appId ApiKey:apiKey];
}

- (void)configurePlacementInfo:(NSDictionary *)placementInfo {
    self.placementInfo = placementInfo;
    
    for (NSString *key in placementInfo) {
        
        NSMutableSet<ZFReformedNativeAd *> *reformedAdsPlacementCachePool = [NSMutableSet<ZFReformedNativeAd *> set];
        [self.reformedAdsCachePool safeSetObject:reformedAdsPlacementCachePool forKey:key];
        
        MVTemplate *template = [MVTemplate templateWithType:MVAD_TEMPLATE_BIG_IMAGE adsNum:MV_NATIVE_ADS_REQUEST_ONCE_COUNT];
        
        [[MVSDK sharedInstance] preloadNativeAdsWithUnitId:[self.placementInfo objectForKey:key]
                                             fbPlacementId:nil
                                        supportedTemplates:@[template]
                                            autoCacheImage:YES
                                                adCategory:MVAD_CATEGORY_ALL];
        
        MVNativeAdManager *manager = [[MVNativeAdManager alloc] initWithUnitID:[self.placementInfo objectForKey:key]
                                        fbPlacementId:nil
                                   supportedTemplates:@[template]
                                       autoCacheImage:YES
                                           adCategory:MVAD_CATEGORY_ALL
                             presentingViewController:nil];
        
        ZFMobvistaNativeAdObserver *observer = [[ZFMobvistaNativeAdObserver alloc] initWithPlacement:key];
        [self.observerRetainArray addObject:observer];
        
        manager.delegate = observer;
        observer.delegate = self;
        
        [self.placementAdsManager safeSetObject:manager forKey:key];
    }
}

- (void)loadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption {
    
    [self.loadImageIndicator safeSetObject:@(loadImageOption) forKey:placementKey];
    
    NSMutableSet<ZFReformedNativeAd *> *reformedAdsPool = [self.reformedAdsCachePool objectForKey:placementKey];
    if (reformedAdsPool.count > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)]) {
            [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformMobvista placement:placementKey];
        }
        return ;
    }
    
    if (self.taskStatus == DPMobvistaStatusBusy) {
        [self printDebugLog:@"【ZFMobvistaNativeAdsManager】the taskStatus is busy"];
        return ;
    }
    
    if (self.placementInfo && [self.placementInfo objectForKey:placementKey]) {
        [self loadAdsForPlacement:placementKey];
        [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】Start loading ads for placement:%@", placementKey]];
        self.taskStatus = DPMobvistaStatusBusy;
        [self printDebugLog:@"【ZFMobvistaNativeAdsManager】the taskStatus change to busy"];
    } else {
        [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】Missing configuration for placement:%@", placementKey]];
    }
}

- (ZFReformedNativeAd *)fetchNativeAd:(NSString *)placementKey {
    
    NSMutableSet<ZFReformedNativeAd *> *reformedAdsPool = [self.reformedAdsCachePool objectForKey:placementKey];
    NSArray<ZFReformedNativeAd *> *loadedReformedAds = [reformedAdsPool allObjects];
    
    ZFReformedNativeAd *reformedAd = nil;
    if ([loadedReformedAds count] > 0) {
        NSUInteger randomIndex = arc4random() % [loadedReformedAds count];
        reformedAd = [loadedReformedAds objectAtIndex:randomIndex];
    
        if (reformedAd) {
            [reformedAdsPool removeObject:reformedAd];
        }
        if (reformedAdsPool) {
            [self.reformedAdsCachePool safeSetObject:reformedAdsPool forKey:placementKey];
        } else {
            [self.reformedAdsCachePool removeObjectForKey:placementKey];
        }
    }
        
    if (reformedAdsPool.count < MV_NATIVE_ADS_POOL_REFILL_THRESHOLD && self.taskStatus == DPMobvistaStatusFree) {
        [self loadAdsForPlacement:placementKey];
        [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】Start loading ads for placement:%@", placementKey]];
        self.taskStatus = DPMobvistaStatusBusy;
        [self printDebugLog:@"【ZFMobvistaNativeAdsManager】the taskStatus change to busy"];
    }
    
//    if (reformedAdsPool.count == 0 && self.delegate && [self.delegate respondsToSelector:@selector(nativeAdStatusLoading:placement:)]) {
//        [self.delegate nativeAdStatusLoading:ZFNativeAdsPlatformMobvista placement:placementKey];
//    }
    
    return reformedAd;
}

- (void)registerAdInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view {
    
    MVCampaign *campaign = objc_getAssociatedObject(reformedAd, &MVReformAdKey);
    NSString *placementKey = objc_getAssociatedObject(reformedAd, &MVAdPlacementKey);
    
    MVNativeAdManager *manager = [self.placementAdsManager objectForKey:placementKey];
    [manager registerViewForInteraction:view withCampaign:campaign];
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】register view %@ with campaign:%@", view, campaign]];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <ZFMobvistaNativeAdObserverDelegate>
- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds placement:(nonnull NSString *)placementKey {
    
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ads loaded:%@ for placement:%@", nativeAds, placementKey]];
    
    ZFNativeAdsLoadImageOption loadImageOption = [[self.loadImageIndicator valueForKey:placementKey] unsignedIntegerValue];
    
    self.totalTaskCount = nativeAds.count;
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】the total task count is %lu", (unsigned long)self.totalTaskCount]];
    
    for (MVCampaign *campaign in nativeAds) {
        
        [self.campaignRetainArray addObject:campaign];
        
        ZFReformedNativeAd *reformedAd = [[ZFReformedNativeAd alloc] init];
        
        reformedAd.platform = ZFNativeAdsPlatformMobvista;
        reformedAd.title = campaign.appName;
        reformedAd.subtitle = campaign.packageName;
        reformedAd.callToAction = campaign.adCall;
        reformedAd.detail = campaign.appDesc;
        reformedAd.adId = campaign.adId;
        
        reformedAd.iconURL = [NSURL URLWithString:campaign.iconUrl];
        reformedAd.coverImageURL = [NSURL URLWithString:campaign.imageUrl];
        
        objc_setAssociatedObject(reformedAd, &MVReformAdKey, campaign, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(reformedAd, &MVAdPlacementKey, placementKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
       
        if (loadImageOption == ZFNativeAdsLoadImageOptionNone) {
            
            [[self.reformedAdsCachePool objectForKey:placementKey] addObject:reformedAd];
            [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】reformed ad did cache:%@", reformedAd]];
            
            self.finishedTaskCount++;
            [self changeTaskStatusIfFinished];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)]) {
                [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformMobvista placement:placementKey];
            }
            
            continue;
        }
        
        if (loadImageOption & ZFNativeAdsLoadImageOptionCover) {
            
            __weak typeof(self) weakSelf = self;
            [campaign loadImageUrlAsyncWithBlock:^(UIImage *image) {
                __strong typeof(weakSelf) self = weakSelf;
                
                if (image) {
                    reformedAd.coverImage = image;
                    
                    if ((loadImageOption & ZFNativeAdsLoadImageOptionIcon) && !reformedAd.iconImage) {
                        return;
                    }
                    
                    [[self.reformedAdsCachePool objectForKey:placementKey] addObject:reformedAd];
                    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】reformed ad did cache:%@", reformedAd]];
                    
                    self.finishedTaskCount++;
                    [self changeTaskStatusIfFinished];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)]) {
                        [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformMobvista placement:placementKey];
                    }
                } else {
                    if (!objc_getAssociatedObject(reformedAd, &MVReformAdErrorKey)) {
                        [self printDebugLog:@"【ZFMobvistaNativeAdsManager】reformed ad image cover load error!"];
                        objc_setAssociatedObject(reformedAd, &MVReformAdErrorKey, @"cover image load failed", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        self.finishedTaskCount++;
                        [self changeTaskStatusIfFinished];
                    }
                }
            }];
        }
        
        if (loadImageOption & ZFNativeAdsLoadImageOptionIcon) {
            
            __weak typeof(self) weakSelf = self;
            [campaign loadIconUrlAsyncWithBlock:^(UIImage *image) {
                __strong typeof(weakSelf) self = weakSelf;
                
                if (image) {
                    reformedAd.iconImage = image;
                    
                    if ((loadImageOption & ZFNativeAdsLoadImageOptionCover) && !reformedAd.coverImage) {
                        return;
                    }
                    
                    [[self.reformedAdsCachePool objectForKey:placementKey] addObject:reformedAd];
                    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】reformed ad did cache:%@", reformedAd]];
                    
                    self.finishedTaskCount++;
                    [self changeTaskStatusIfFinished];
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidLoad:placement:)]) {
                        [self.delegate nativeAdDidLoad:ZFNativeAdsPlatformMobvista placement:placementKey];
                    }
                } else {
                    if (!objc_getAssociatedObject(reformedAd, &MVReformAdErrorKey)) {
                        [self printDebugLog:@"【ZFMobvistaNativeAdsManager】reformed ad icon cover load error!"];
                        objc_setAssociatedObject(reformedAd, &MVReformAdErrorKey, @"icon image load failed", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        self.finishedTaskCount++;
                        [self changeTaskStatusIfFinished];
                    }
                }
            }];
        }
        
    }
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error placement:(nonnull NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ads load failed:%@ for placement:%@", error, placementKey]];
    
    self.taskStatus = DPMobvistaStatusFree;
    self.totalTaskCount = 0;
    self.finishedTaskCount = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidFail:placement:error:)]) {
        [self.delegate nativeAdDidFail:ZFNativeAdsPlatformMobvista placement:placementKey error:error];
    }
}

- (void)nativeAdDidClick:(nonnull MVCampaign *)nativeAd placement:(NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ad did click:%@ for placement:%@", nativeAd, placementKey]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeAdDidClick:placement:)]) {
        [self.delegate nativeAdDidClick:ZFNativeAdsPlatformMobvista placement:placementKey];
    }
    
}

- (void)nativeAdClickUrlWillStartToJump:(nonnull NSURL *)clickUrl placement:(nonnull NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ad click url will start to jump:%@ for placement:%@", clickUrl, placementKey]];
}

- (void)nativeAdClickUrlDidJumpToUrl:(nonnull NSURL *)jumpUrl placement:(nonnull NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ads click url did jump to url:%@ for placement:%@", jumpUrl, placementKey]];
}

- (void)nativeAdClickUrlDidEndJump:(nullable NSURL *)finalUrl
                             error:(nullable NSError *)error
                         placement:(nonnull NSString *)placementKey {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】native ads did end jump to final url:%@ error:%@ for placement:%@", finalUrl, error, placementKey]];
}

#pragma mark - private methods
- (void)loadAdsForPlacement:(NSString *)placementKey {
    MVNativeAdManager *manager = [self.placementAdsManager objectForKey:placementKey];
    [manager loadAds];
}

- (void)printDebugLog:(NSString *)debugLog {
    if (self.debugLogEnable) {
        NSLog(@"%@", debugLog);
    }
}

- (void)changeTaskStatusIfFinished {
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】the finished task count is %lu", (unsigned long)self.finishedTaskCount]];
    if (self.finishedTaskCount >= self.totalTaskCount) {
        self.finishedTaskCount = 0;
        self.totalTaskCount = 0;
        self.taskStatus = DPMobvistaStatusFree;
        [self printDebugLog:@"【ZFMobvistaNativeAdsManager】the taskStatus change to free"];
    }
}

#pragma mark - setters

- (void)setDebugLogEnable:(BOOL)enable {
    _debugLogEnable = enable;
}

#pragma mark - getters
- (NSMutableDictionary *)placementAdsManager {
    if (!_placementAdsManager) {
        _placementAdsManager = [NSMutableDictionary dictionary];
    }
    return _placementAdsManager;
}


- (NSMutableDictionary *)loadImageIndicator {
    if (!_loadImageIndicator) {
        _loadImageIndicator = [NSMutableDictionary dictionary];
    }
    return _loadImageIndicator;
}

- (NSMutableDictionary *)reformedAdsCachePool {
    if (!_reformedAdsCachePool) {
        _reformedAdsCachePool = [NSMutableDictionary dictionary];
    }
    return _reformedAdsCachePool;
}

- (NSMutableArray<ZFMobvistaNativeAdObserver *> *)observerRetainArray {
    if (!_observerRetainArray) {
        _observerRetainArray = [NSMutableArray<ZFMobvistaNativeAdObserver *> array];
    }
    return _observerRetainArray;
}

- (NSMutableArray<MVCampaign *> *)campaignRetainArray {
    if (!_campaignRetainArray) {
        _campaignRetainArray = [NSMutableArray<MVCampaign *> array];
    }
    return _campaignRetainArray;
}


@end
