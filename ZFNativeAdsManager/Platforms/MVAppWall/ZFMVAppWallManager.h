//
//  ZFMVAppWallManager.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/23/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFMVAppWallManager : NSObject

+ (instancetype)sharedInstance;

- (void)configureAppWallWithUnitId:(NSString *)unitId navigationController:(UINavigationController *)navigationController;

- (void)preloadAppWall:(NSString *)appWallUnitId;

- (void)showAppWall;

- (void)setDebugLogEnable:(BOOL)enable;

@end
