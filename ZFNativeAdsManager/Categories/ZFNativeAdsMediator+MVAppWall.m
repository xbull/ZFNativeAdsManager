//
//  ZFNativeAdsMediator+MVAppWall.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/23/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFNativeAdsMediator+MVAppWall.h"

NSString *const kZFNativeAdsMediatorTargetMVAppWall = @"MVAppWall";

NSString *const kZFNativeAdsMediatorActionConfigureMVAppWallInfo = @"configureAppWallInfo";
NSString *const kZFNativeAdsMediatorActionPreloadMVAppWall = @"preloadAppWall";
NSString *const kZFNativeAdsMediatorActionShowMVAppWall = @"showAppWall";


@implementation ZFNativeAdsMediator (MVAppWall)

- (void)ZFNativeAdsMediator_configureMVAppWallWithUnitId:(NSString *)unitId navigationController:(UINavigationController *)navigationController {
    
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    if (unitId) {
        [paramsDict setObject:unitId forKey:@"unitId"];
    }
    
    if (navigationController) {
        [paramsDict setObject:navigationController forKey:@"navigationController"];
    }
    
    [self performTarget:kZFNativeAdsMediatorTargetMVAppWall
                 action:kZFNativeAdsMediatorActionConfigureMVAppWallInfo
                 params:[NSDictionary dictionaryWithDictionary:paramsDict]
      shouldCacheTarget:YES];
}

- (void)ZFNativeAdsMediator_preloadMVAppWall {
    [self performTarget:kZFNativeAdsMediatorTargetMVAppWall
                 action:kZFNativeAdsMediatorActionPreloadMVAppWall
                 params:@{}
      shouldCacheTarget:YES];
}

- (void)ZFNativeAdsMediator_showMVAppWall {
    [self performTarget:kZFNativeAdsMediatorTargetMVAppWall
                 action:kZFNativeAdsMediatorActionShowMVAppWall
                 params:@{}
      shouldCacheTarget:YES];
}

@end
