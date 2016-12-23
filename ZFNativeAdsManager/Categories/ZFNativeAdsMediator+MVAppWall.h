//
//  ZFNativeAdsMediator+MVAppWall.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/23/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFNativeAdsMediator.h"

@interface ZFNativeAdsMediator (MVAppWall)

- (void)ZFNativeAdsMediator_configureMVAppWallWithUnitId:(NSString *)unitId navigationController:(UINavigationController *)navigationController;

- (void)ZFNativeAdsMediator_preloadMVAppWall;

- (void)ZFNativeAdsMediator_showMVAppWall;

@end
