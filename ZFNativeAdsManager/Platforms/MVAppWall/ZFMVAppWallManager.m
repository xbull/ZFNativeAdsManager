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

- (void)preloadAppWall:(NSString *)appWallUnitId {
    [[MVSDK sharedInstance] preloadAppWallAdsWithUnitId:appWallUnitId];
}

- (void)showAppWall {
    if (!self.appWallManager) {
        [self printDebugLog:@"show app wall failed. Please configure app wall before showing"];
        return;
    }
    
    [self.appWallManager showAppWall];
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
