//
//  JSAdmobInterstitialAdsManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "JSAdmobInterstitialAdsManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static JSAdmobInterstitialAdsManager *_instance = nil;

@interface JSAdmobInterstitialAdsManager () <GADInterstitialDelegate>

@property (nonatomic, strong) NSString        *adUnitId;
@property (nonatomic, strong) GADInterstitial *interstitial;

@end


@implementation JSAdmobInterstitialAdsManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[JSAdmobInterstitialAdsManager alloc] init];
    });
    return _instance;
}

#pragma mark - Public method

- (void)startWithAdUnitId:(NSString *)adUnitId {
    self.adUnitId = adUnitId;
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:rootViewController];
    }
}

#pragma mark - Private method

- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.adUnitId];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    
    return interstitial;
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"【JSAdmobInterstitialAdsManager】Ad did dismiss screen");
    
    self.interstitial = [self createAndLoadInterstitial];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidDismissScreen:)]) {
        [self.delegate interstitialDidDismissScreen:interstitial];
    }
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"【JSAdmobInterstitialAdsManager】Succeed to receive Ad");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidReceiveAd:)]) {
        [self.delegate interstitialDidReceiveAd:interstitial];
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"【JSAdmobInterstitialAdsManager】Failed to receive Ad: %@", error.localizedDescription);
    self.interstitial = [self createAndLoadInterstitial];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidFailToReceiveAdWithError:)]) {
        [self.delegate interstitialDidFailToReceiveAdWithError:error];
    }
}

@end
