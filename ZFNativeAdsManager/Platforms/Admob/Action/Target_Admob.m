//
//  Target_Admob.m
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "Target_Admob.h"
#import "JSAdmobInterstitialAdsManager.h"

@implementation Target_Admob

- (void)Action_setDelegate:(NSDictionary *)params {
    id<JSInterstitialAdsDelegate> delegate = [params objectForKey:@"delegate"];
    [JSAdmobInterstitialAdsManager sharedInstance].delegate = delegate;
}

- (void)Action_startAdmobWithAdUnitId:(NSDictionary *)params {
    NSString *adUnitId = [params objectForKey:@"adUnitId"];
    [[JSAdmobInterstitialAdsManager sharedInstance] startWithAdUnitId:adUnitId];
}

- (void)Action_showAdmobFromRootViewController:(NSDictionary *)params {
    UIViewController *rootVC = [params objectForKey:@"rootViewController"];
    return [[JSAdmobInterstitialAdsManager sharedInstance] showInterstitialFromRootViewController:rootVC];
}

@end
