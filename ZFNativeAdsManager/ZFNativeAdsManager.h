//
//  ZFNativeAdsManager.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFNativeAdsDefine.h"
#import "ZFReformedNativeAd.h"

typedef void (^ZFReformedAdFetchBlock)(ZFReformedNativeAd *reformedAd);

@protocol ZFNativeAdsManagerDelegate <NSObject>

@optional
/**
 
 If implemented, this will get called when user click the native ads.
 
 * Notice: Some platforms (e.g. Mobvista) will not jump right after clicking.

 @param placementKey setting by method [configurePlacementInfo:platform]
 */
- (void)nativeAdDidClick:(NSString *)placementKey;

@end

@interface ZFNativeAdsManager : NSObject

/**
 * Singleton
 */
+ (instancetype)sharedInstance;

// ========================================> Native Ads Begin <==========================================

/**
 
 Configure appId and apiKey for platform.
 
 * Notice: You don't need to call this for following platforms:
    - Facebook

 @param appId indicates appId for certain platform.
 @param apiKey indicates apiKey for certain platform.
 @param platform : native ads platform, which is defined by ZFNativeAdsPlatform
 */
- (void)configureAppId:(NSString *)appId apiKey:(NSString *)apiKey platform:(ZFNativeAdsPlatform)platform;

/**
 
 Configure ids of all placement for certain platform.

 @param placementInfo includes all ids for all placements. 
        The placementKey is defined as you wish, the corresponding value is your placementID applied in your page for the platform.
 
 @param platform : native ads platform, which is defined by ZFNativeAdsPlatform
 */
- (void)configurePlacementInfo:(NSDictionary *)placementInfo platform:(ZFNativeAdsPlatform)platform;

/**
 
 Set the priority for all platforms to determine the fetching order when they are simultaneously loaded.
 
 @param priorityArray : And array indicates the priority of the platforms, elements is NSNumber type of ZFNativeAdsPlatform enum.
 (e.g. @[@(ZFNativeAdsPlatformFacebook), @(ZFNativeAdsPlatformMobvista)]
 
 * [Warning] !!! : You must set priority for the platform that you want to load and fetch native ads.
 * That is, If you don't set the priority of platform A, even if you've configured the app info for platform A, the native ads from platform A will not be loaded.

 */
- (void)setPriority:(NSArray<NSNumber *> *)priorityArray;



- (void)setCapacity:(NSUInteger)capacity forPlacement:(NSString *)placementKey;

/**
 
 Preload the ads for certain placement. This may improve the experience for showing native ads. But this will reduce the impression ratio.

 @param placementKey setting by method [configurePlacementInfo:platform]
 @param loadImageOption indicates the resource that native ads need to load. 
        You can set multiple options.(e.g. ZFNativeAdsLoadImageOptionIcon | ZFNativeAdsLoadImageCover)
 */
- (void)preloadNativeAds:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption;

/**
 
 Fetch native ad instantly for certain placement.
 This will return nil if you don't preload ads for the corresponding placement.

 @param placementKey setting by method [configurePlacementInfo:platform]
 @return loaded native ads.
 */
- (ZFReformedNativeAd *)fetchPreloadAdForPlacement:(NSString *)placementKey;

- (NSArray<ZFReformedNativeAd *> *)fetchPreloadAdForPlacement:(NSString *)placementKey count:(NSUInteger)count;

/**
 
 Fetch native ad for certain placement.

 @param placementKey setting by method [configurePlacementInfo:platform]
 @param loadImageOption indicates the resource that native ads need to load.
        This parameter will be invalid if native ads from this placement are preloaded by method [preloadNativeAds:loadImageOption].
 @param fetchblock return the native ad. May return nil when native ads fail to load.
 */
- (void)fetchAdForPlacement:(NSString *)placementKey loadImageOption:(ZFNativeAdsLoadImageOption)loadImageOption fetchBlock:(ZFReformedAdFetchBlock)fetchblock;

/**
 
 Bind Ad and view for user click interaction.

 @param reformedAd : reformed native ads.
 @param view : view that shows natives ads and receive click interaction.
 */
- (void)registAdForInteraction:(ZFReformedNativeAd *)reformedAd view:(UIView *)view;

/**
 
 Fetch an adChoiceView according to Native Ads guidelines for each platform.
 
 return nil when adChoiceView is not necessary for certain reformedAd.

 @param reformedAd getting by method [fetchAdForPlacement:loadImageOption:fetchBlock] or [fetchPreloadAdForPlacement:]
 @param corner determine the orientation that adChoiceView expands.
 @return the adchoiceView for referal reformedAd, return nil when adChoiceView is not necessary.
 */
- (UIView *)fetchAdChoiceView:(ZFReformedNativeAd *)reformedAd corner:(UIRectCorner)corner;

@property (nonatomic, weak) id<ZFNativeAdsManagerDelegate> delegate;

@property (nonatomic, assign) BOOL mobvistaRefine;//default is NO

// ========================================> Native Ads End <==========================================

// ========================================> Appwall Begin <==========================================

/**
 
 Initialize the native ads manager.
 
 @param unitId The id of the ad unit. You can create your unit id from our Portal.
 @param navigationController The UINavigationController that will be used to push App Wall Controller. If not set, it will be the root viewController of your current UIWindow. But it may failed to push our AppWall view controller if your rootViewController is not a navigation controller. So set this property is necessary.
 */
- (void)configureAppWallWithUnitId:(NSString *)unitId navigationController:(UINavigationController *)navigationController;

/**
 The method that kicks off the preloading of app wall ads. It may be called again in the future to refresh the ads manually.
 You must init app wall before calling this method.
 */
- (void)preloadAppWall:(NSString *)appWallUnitId;

/**
 Present app wall modally or push app wall in your navigation controller. It depends on how you init the manager.
 */
- (void)showAppWall;

// ========================================> Appwall End <==========================================

/**
 
 Set debug log enable or not. Default is NO.

 @param enable indicates whether or not show dubug log.
 */
- (void)setDebugLogEnable:(BOOL)enable;

@end
