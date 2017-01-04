//
//  JSAdmobInterstitialAdsManager.h
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSInterstitialAdsDefine.h"

@interface JSAdmobInterstitialAdsManager : NSObject

@property (nonatomic, weak) id<JSInterstitialAdsDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)startWithAdUnitId:(NSString *)adUnitId;
- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController;

@end
