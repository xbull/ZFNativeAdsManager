//
//  ZFViewController.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/6/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFViewController.h"
#import <Masonry/Masonry.h>
#import "ZFNativeAdsManager.h"
#import "JSInterstitialAdsManager.h"
#import "DPFeedViewController.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface ZFViewController () <ZFNativeAdsManagerDelegate>

@property (nonatomic, strong) UIView *preloadAdView;
@property (nonatomic, strong) UIImageView *preloadImageView;
@property (nonatomic, strong) UILabel *preloadLabel;

@property (nonatomic, strong) UIView *loadAdView;
@property (nonatomic, strong) UIImageView *loadImageView;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UILabel *loadLabel;

@property (nonatomic, strong) UIButton *appWallButton;

@property (nonatomic, strong) UIButton *interstitialButton;

@property (nonatomic, strong) UIButton *feedAdsButton;

@property (nonatomic, strong) UIView *adChoiceContainingView;

@end

@implementation ZFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configureViews];
    
    [self configureAdsInfo];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureViews {
    
    [self.view addSubview:self.preloadAdView];
    [self.preloadAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).multipliedBy(0.4);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(self.preloadAdView.mas_width).multipliedBy(0.6);
    }];
    
    [self.preloadAdView addSubview:self.preloadImageView];
    [self.preloadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.preloadAdView);
    }];
    
    [self.preloadAdView addSubview:self.adChoiceContainingView];
    [self.adChoiceContainingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.preloadAdView);
        make.right.equalTo(self.preloadAdView);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.preloadLabel];
    [self.preloadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.preloadAdView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.loadAdView];
    [self.loadAdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).multipliedBy(0.8);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.equalTo(self.loadAdView.mas_width).multipliedBy(0.6);
    }];
    
    [self.loadAdView addSubview:self.loadImageView];
    [self.loadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.loadAdView);
    }];
    
    [self.view addSubview:self.loadLabel];
    [self.loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadAdView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.appWallButton];
    [self.appWallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(10);
        make.top.equalTo(self.loadLabel.mas_bottom).with.offset(10);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(40);
    }];
    
    [self.view addSubview:self.loadButton];
    [self.loadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.appWallButton.mas_right).with.offset(20);
        make.right.equalTo(self.view).with.offset(-10);
        make.top.equalTo(self.appWallButton);
        make.height.mas_equalTo(40);
    }];
    
    [self.view addSubview:self.interstitialButton];
    [self.interstitialButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.appWallButton.mas_bottom).offset(5);
        make.height.equalTo(self.appWallButton);
        make.left.equalTo(self.appWallButton);
        make.width.equalTo(self.appWallButton).multipliedBy(2);
    }];
    
    [self.view addSubview:self.feedAdsButton];
    [self.feedAdsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.appWallButton.mas_bottom).offset(5);
        make.height.equalTo(self.appWallButton);
        make.left.equalTo(self.interstitialButton.mas_right).with.offset(10);
        make.right.equalTo(self.view).with.offset(-10);
    }];
}

- (void)configureAdsInfo {
    
    [ZFNativeAdsManager sharedInstance].delegate = self;
    [[ZFNativeAdsManager sharedInstance] setDebugLogEnable:YES];
    [[ZFNativeAdsManager sharedInstance] configureAppId:@"25784" apiKey:@"7e03a2daee806fefa292d1447ea50155" platform:ZFNativeAdsPlatformMobvista];
    [[ZFNativeAdsManager sharedInstance] configurePlacementInfo:@{@"preload" : @"1169668629790481_1169669976457013",
                                                                  @"syncload" : @"962085583908347_962089450574627"}
                                                       platform:ZFNativeAdsPlatformFacebook];
    [[ZFNativeAdsManager sharedInstance] configurePlacementInfo:@{@"preload" : @"1497",
                                                                  @"syncload" : @"4157"}
                                                       platform:ZFNativeAdsPlatformMobvista];
    [[ZFNativeAdsManager sharedInstance] configureAppWallWithUnitId:@"1498" navigationController:nil];
    [[ZFNativeAdsManager sharedInstance] setPriority:@[@(ZFNativeAdsPlatformFacebook),
                                                       @(ZFNativeAdsPlatformMobvista)]];
    [ZFNativeAdsManager sharedInstance].mobvistaRefine = YES;
    
//    [[ZFNativeAdsManager sharedInstance] setPriority:@[@(ZFNativeAdsPlatformMobvista)]];
    
//    [[ZFNativeAdsManager sharedInstance] setPriority:@[@(ZFNativeAdsPlatformFacebook)]];
    
    [[ZFNativeAdsManager sharedInstance] setCapacity:5 forPlacement:@"preload"];
    [[ZFNativeAdsManager sharedInstance] preloadNativeAds:@"preload" loadImageOption:ZFNativeAdsLoadImageOptionCover];
    [[ZFNativeAdsManager sharedInstance] preloadAppWall:@"1498"];
    
    [[JSInterstitialAdsManager sharedInstance] startWithAdUnitId:@"ca-app-pub-3940256099942544/4411468910"];
    
    [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
    
}

#pragma mark - <ZFNativeAdsManagerDelegate>

- (void)nativeAdDidClick:(NSString *)placementKey {
    
    NSLog(@"Placement:%@ did click!", placementKey);
    
    __weak typeof(self) weakSelf = self;
    [[ZFNativeAdsManager sharedInstance] fetchAdForPlacement:placementKey loadImageOption:ZFNativeAdsLoadImageOptionCover fetchBlock:^(ZFReformedNativeAd *reformedAd) {
        __strong typeof(weakSelf) self = weakSelf;
        [self renderAd:reformedAd placement:placementKey];
    }];
}

#pragma mark - action methods
- (void)onLoadAds {
    [self.loadButton setEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [[ZFNativeAdsManager sharedInstance] fetchAdForPlacement:@"preload" loadImageOption:ZFNativeAdsLoadImageOptionCover fetchBlock:^(ZFReformedNativeAd *reformedAd) {
        __strong typeof(weakSelf) self = weakSelf;
        [self renderAd:reformedAd placement:@"preload"];
    }];
    
    [[ZFNativeAdsManager sharedInstance] fetchAdForPlacement:@"syncload" loadImageOption:ZFNativeAdsLoadImageOptionCover fetchBlock:^(ZFReformedNativeAd *reformedAd) {
        __strong typeof(weakSelf) self = weakSelf;
        [self renderAd:reformedAd placement:@"syncload"];
    }];
}

- (void)showAppWall {
    [[ZFNativeAdsManager sharedInstance] showAppWall];
}

- (void)showInterstitial {
    if (JSInterstitialAdStatusReady != [JSInterstitialAdsManager sharedInstance].interstitialAdStatus) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"The interstitial is not ready now, try a few seconds later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        [[JSInterstitialAdsManager sharedInstance] showFromViewController:self];
    }
//    NSArray *array = [[ZFNativeAdsManager sharedInstance] fetchPreloadAdForPlacement:@"preload" count:5];
//    NSLog(@">>>>>>>>>>>%@", array);
}

- (void)showFeedAds {
//    [[ZFNativeAdsManager sharedInstance] setCapacity:5 forPlacement:@"preload"];
//    [[ZFNativeAdsManager sharedInstance] preloadNativeAds:@"preload" loadImageOption:ZFNativeAdsLoadImageOptionCover];
    DPFeedViewController *feedVC = [[DPFeedViewController alloc] init];
    [self presentViewController:feedVC animated:YES completion:nil];
}

#pragma mark - Private methods
- (void)renderAd:(ZFReformedNativeAd *)reformedAd placement:(NSString *)placementKey {
    
    if ([placementKey isEqualToString:@"preload"]) {
        
        for (UIView *subView in self.adChoiceContainingView.subviews) {
            [subView removeFromSuperview];
        }
        
        UIView *adChoiceView = [[ZFNativeAdsManager sharedInstance] fetchAdChoiceView:reformedAd corner:UIRectCornerTopRight];
        [self.adChoiceContainingView addSubview:adChoiceView];
        [adChoiceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.adChoiceContainingView);
        }];
        
        self.preloadImageView.image = reformedAd.coverImage;
        [[ZFNativeAdsManager sharedInstance] registAdForInteraction:reformedAd view:self.preloadAdView];
        
        [self.adChoiceContainingView layoutIfNeeded];
        
    } else if ([placementKey isEqualToString:@"syncload"]) {
        
        self.loadImageView.image = reformedAd.coverImage;
        [[ZFNativeAdsManager sharedInstance] registAdForInteraction:reformedAd view:self.loadAdView];
    }
}

#pragma mark - Getters
- (UIView *)preloadAdView {
    if (!_preloadAdView) {
        _preloadAdView = [[UIView alloc] init];
        _preloadAdView.backgroundColor = [UIColor grayColor];
        _preloadAdView.clipsToBounds = YES;
    }
    return _preloadAdView;
}

- (UIImageView *)preloadImageView {
    if (!_preloadImageView) {
        _preloadImageView = [[UIImageView alloc] init];
        _preloadImageView.backgroundColor = [UIColor clearColor];
        _preloadImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _preloadImageView;
}

- (UILabel *)preloadLabel {
    if (!_preloadLabel) {
        _preloadLabel = [[UILabel alloc] init];
        _preloadLabel.text = @"Preload";
        _preloadLabel.textColor = [UIColor whiteColor];
        _preloadLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _preloadLabel;
}

- (UIView *)loadAdView {
    if (!_loadAdView) {
        _loadAdView = [[UIView alloc] init];
        _loadAdView.backgroundColor = [UIColor lightGrayColor];
        _loadAdView.clipsToBounds = YES;
    }
    return _loadAdView;
}

- (UIImageView *)loadImageView {
    if (!_loadImageView) {
        _loadImageView = [[UIImageView alloc] init];
        _loadImageView.backgroundColor = [UIColor clearColor];
        _loadImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _loadImageView;
}

- (UIView *)adChoiceContainingView {
    if (!_adChoiceContainingView) {
        _adChoiceContainingView = [[UIView alloc] init];
        _adChoiceContainingView.backgroundColor = [UIColor clearColor];
    }
    return _adChoiceContainingView;
}

- (UILabel *)loadLabel {
    if (!_loadLabel) {
        _loadLabel = [[UILabel alloc] init];
        _loadLabel.text = @"Load";
        _loadLabel.textAlignment = NSTextAlignmentCenter;
        _loadLabel.textColor = [UIColor whiteColor];
    }
    return _loadLabel;
}

- (UIButton *)loadButton {
    if (!_loadButton) {
        _loadButton = [[UIButton alloc] init];
        [_loadButton setTitle:@"Start Load" forState:UIControlStateNormal];
        [_loadButton setTitle:@"Loading" forState:UIControlStateDisabled];
        [_loadButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_loadButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        _loadButton.backgroundColor = [UIColor lightGrayColor];
        [_loadButton addTarget:self action:@selector(onLoadAds) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loadButton;
}

- (UIButton *)appWallButton {
    if (!_appWallButton) {
        _appWallButton = [[UIButton alloc] init];
        [_appWallButton setTitle:@"AppWall" forState:UIControlStateNormal];
        [_appWallButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _appWallButton.backgroundColor = [UIColor lightGrayColor];
        [_appWallButton addTarget:self action:@selector(showAppWall) forControlEvents:UIControlEventTouchUpInside];
    }
    return _appWallButton;
}

- (UIButton *)interstitialButton {
    if (!_interstitialButton) {
        _interstitialButton = [[UIButton alloc] init];
        [_interstitialButton setTitle:@"Interstitial" forState:UIControlStateNormal];
        [_interstitialButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _interstitialButton.backgroundColor = [UIColor lightGrayColor];
        [_interstitialButton addTarget:self action:@selector(showInterstitial) forControlEvents:UIControlEventTouchUpInside];
    }
    return _interstitialButton;
}

- (UIButton *)feedAdsButton {
    if (!_feedAdsButton) {
        _feedAdsButton = [[UIButton alloc] init];
        [_feedAdsButton setTitle:@"feedAds" forState:UIControlStateNormal];
        [_feedAdsButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_feedAdsButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        _feedAdsButton.backgroundColor = [UIColor lightGrayColor];
        [_feedAdsButton addTarget:self action:@selector(showFeedAds) forControlEvents:UIControlEventTouchUpInside];
    }
    return _feedAdsButton;
}



@end
