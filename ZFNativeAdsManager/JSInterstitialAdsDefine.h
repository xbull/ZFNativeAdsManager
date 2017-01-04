//
//  JSInterstitialAdsDefine.h
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#ifndef JSInterstitialAdsDefine_h
#define JSInterstitialAdsDefine_h

typedef NS_ENUM(NSInteger, JSInterstitialAdsPlatform) {
    JSInterstitialAdsPlatformAdmob = 0,
    JSInterstitialAdsPlatformCount
};

@protocol JSInterstitialAdsDelegate <NSObject>

- (void)interstitialDidReceiveAd:(id)ad;
- (void)interstitialDidFailToReceiveAdWithError:(NSError *)error;
- (void)interstitialDidDismissScreen:(id)interstitial;

@end

#endif /* JSInterstitialAdsDefine_h */
