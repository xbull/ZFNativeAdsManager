//
//  JSInterstitialAdsManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "JSInterstitialAdsManager.h"
#import "ZFNativeAdsMediator+Admob.h"

static JSInterstitialAdsManager *_instance = nil;

@interface JSInterstitialAdsManager ()<JSInterstitialAdsDelegate>

@end


@implementation JSInterstitialAdsManager

+ (instancetype)sharedInstance {
    static JSInterstitialAdsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JSInterstitialAdsManager alloc] init];
    });
    return instance;
}

- (void)startWithAdUnitId:(NSString *)adUnitId {
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_startWithAdUnitId:adUnitId];
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_setAdmobDelegate:self];
    
    self.interstitialAdStatus = JSInterstitialAdStatusLoading;
}

- (void)showFromViewController:(UIViewController *)viewController {
    [[ZFNativeAdsMediator sharedInstance] ZFNativeAdsMediator_showFromRootViewController:viewController];
}

- (void)interstitialDidReceiveAd:(id)ad{
    self.interstitialAdStatus = JSInterstitialAdStatusReady;
}

- (void)interstitialDidFailToReceiveAdWithError:(NSError *)error {
    self.interstitialAdStatus = JSInterstitialAdStatusFailed;
}

- (void)interstitialDidDismissScreen:(id)interstitial {
    self.interstitialAdStatus = JSInterstitialAdStatusDismissed;
}

@end
