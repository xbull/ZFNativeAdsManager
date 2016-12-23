//
//  Target_MVAppWall.m
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/23/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import "Target_MVAppWall.h"
#import "ZFMVAppWallManager.h"

@implementation Target_MVAppWall

- (void)Action_configureAppWallInfo:(NSDictionary *)params {
    NSString *unitId = [params objectForKey:@"unitId"];
    UINavigationController *navigationController = [params objectForKey:@"navigationController"];
    [[ZFMVAppWallManager sharedInstance] configureAppWallWithUnitId:unitId navigationController:navigationController];
}

- (void)Action_preloadAppWall:(NSDictionary *)params {
    [[ZFMVAppWallManager sharedInstance] preloadAppWall];
}

- (void)Action_showAppWall:(NSDictionary *)params {
    [[ZFMVAppWallManager sharedInstance] showAppWall];
}

@end
