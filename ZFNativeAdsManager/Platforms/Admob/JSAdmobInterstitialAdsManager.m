//
//  JSAdmobInterstitialAdsManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "JSAdmobInterstitialAdsManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define kMaxFailureCount 5

static JSAdmobInterstitialAdsManager *_instance = nil;

@interface JSAdmobInterstitialAdsManager () <GADInterstitialDelegate>

@property (nonatomic, strong) NSString        *adUnitId;
@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, assign) NSUInteger      failureCount;

@end


@implementation JSAdmobInterstitialAdsManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[JSAdmobInterstitialAdsManager alloc] init];
        _instance.failureCount = 0;
    });
    return _instance;
}

#pragma mark - Public method

- (void)startWithAdUnitId:(NSString *)adUnitId {
    self.adUnitId = adUnitId;
    [self createAndLoadInterstitial];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:rootViewController];
    }
}

#pragma mark - Private method

- (void)createAndLoadInterstitial {
    if (self.failureCount > kMaxFailureCount) {
        return;
    }
    
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.adUnitId];
    self.interstitial.delegate = self;
    [self.interstitial loadRequest:[GADRequest request]];
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"【JSAdmobInterstitialAdsManager】Ad did dismiss screen");
    
    [self createAndLoadInterstitial];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidDismissScreen:)]) {
        [self.delegate interstitialDidDismissScreen:interstitial];
    }
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    if (self.failureCount > 0) {
        self.failureCount -= 1;
    }
    
    NSLog(@"【JSAdmobInterstitialAdsManager】Succeed to receive Ad");
    
    if (interstitial.hasBeenUsed) {
        [self createAndLoadInterstitial];
        return;
    }
    
    if (!interstitial.hasBeenUsed && self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidReceiveAd:)]) {
        [self.delegate interstitialDidReceiveAd:interstitial];
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    self.failureCount += 1;
    
    NSLog(@"【JSAdmobInterstitialAdsManager】Failed to receive Ad: %@", error.localizedDescription);
    [self createAndLoadInterstitial];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialDidFailToReceiveAdWithError:)]) {
        [self.delegate interstitialDidFailToReceiveAdWithError:error];
    }
}

@end
