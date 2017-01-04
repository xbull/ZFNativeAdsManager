//
//  ZFNativeAdsMediator+Admob.m
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "ZFNativeAdsMediator+Admob.h"

NSString *const kZFNativeAdsMediatorTargetAdmob = @"Admob";

NSString *const kZFNativeAdsMediatorActionSetAdmobDelegate = @"setDelegate";
NSString *const kZFNativeAdsMediatorActionStartAdmob = @"startAdmobWithAdUnitId";
NSString *const kZFNativeAdsMediatorActionShowAdmob = @"showAdmobFromRootViewController";

@implementation ZFNativeAdsMediator (Admob)

- (void)ZFNativeAdsMediator_setAdmobDelegate:(id<JSInterstitialAdsDelegate>)delegate {
    [self performTarget:kZFNativeAdsMediatorTargetAdmob
                 action:kZFNativeAdsMediatorActionSetAdmobDelegate
                 params:@{@"delegate" : delegate}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_startWithAdUnitId:(NSString *)adUnitId {
    [self performTarget:kZFNativeAdsMediatorTargetAdmob
                 action:kZFNativeAdsMediatorActionStartAdmob
                 params:@{@"adUnitId" : adUnitId}
      shouldCacheTarget:NO];
}

- (void)ZFNativeAdsMediator_showFromRootViewController:(UIViewController *)rootViewController {
    [self performTarget:kZFNativeAdsMediatorTargetAdmob
                 action:kZFNativeAdsMediatorActionShowAdmob
                 params:@{@"rootViewController" : rootViewController}
      shouldCacheTarget:NO];
}

@end
