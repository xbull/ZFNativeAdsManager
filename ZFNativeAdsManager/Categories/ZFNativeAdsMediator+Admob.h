//
//  ZFNativeAdsMediator+Admob.h
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "ZFNativeAdsMediator.h"
#import "JSInterstitialAdsDefine.h"

@interface ZFNativeAdsMediator (Admob)

- (void)ZFNativeAdsMediator_setAdmobDelegate:(id<JSInterstitialAdsDelegate>)delegate;

- (void)ZFNativeAdsMediator_startWithAdUnitId:(NSString *)adUnitId;

- (void)ZFNativeAdsMediator_showFromRootViewController:(UIViewController *)rootViewController;

@end
