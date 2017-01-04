//
//  JSInterstitialAdsManager.h
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JSInterstitialAdStatus) {
    JSInterstitialAdStatusLoading = 0,
    JSInterstitialAdStatusReady,
    JSInterstitialAdStatusFailed,
    JSInterstitialAdStatusDismissed
};

@interface JSInterstitialAdsManager : NSObject

@property (nonatomic, assign) JSInterstitialAdStatus interstitialAdStatus;

+ (instancetype)sharedInstance;

- (void)startWithAdUnitId:(NSString *)adUnitId;

- (void)showFromViewController:(UIViewController *)viewController;

@end
