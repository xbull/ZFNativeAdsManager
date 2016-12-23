//
//  ZFMVAppWallManager.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/23/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "ZFMVAppWallManager.h"
#import <MVSDKAppWall/MVWallAdManager.h>
#import <MVSDK/MVSDK.h>

@interface ZFMVAppWallManager ()

@property (nonatomic, strong) MVWallAdManager *appWallManager;

@property (nonatomic, strong) NSString *appWallUnitId;

@property (nonatomic, assign) BOOL debugLogEnable;

@end

@implementation ZFMVAppWallManager

+ (instancetype)sharedInstance {
    
    static ZFMVAppWallManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZFMVAppWallManager alloc] init];
    });
    return instance;
}

- (void)configureAppWallWithUnitId:(NSString *)unitId navigationController:(UINavigationController *)navigationController {
    if (unitId && unitId.length > 0) {
        self.appWallManager = [[MVWallAdManager alloc] initWithUnitID:unitId withNavigationController:navigationController];
    }
}

- (void)preloadAppWall {
    if (self.appWallUnitId) {
        [[MVSDK sharedInstance] preloadAppWallAdsWithUnitId:self.appWallUnitId];
    } else {
        [self printDebugLog:@"preload app wall failed. Please configure app wall before preload"];
    }
}

- (void)showAppWall {
    if (!self.appWallManager) {
        [self printDebugLog:@"show app wall failed. Please configure app wall before showing"];
        return;
    }
    
    [self.appWallManager showAppWall];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self preloadAppWall];
    });
}

- (void)setDebugLogEnable:(BOOL)enable {
    self.debugLogEnable = enable;
}

#pragma mark - private methods
- (void)printDebugLog:(NSString *)debugLog {
    if (self.debugLogEnable) {
        NSLog(@"%@", debugLog);
    }
}

@end
