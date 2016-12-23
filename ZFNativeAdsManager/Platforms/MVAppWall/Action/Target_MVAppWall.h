//
//  Target_MVAppWall.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/23/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target_MVAppWall : NSObject

- (void)Action_configureAppWallInfo:(NSDictionary *)params;

- (void)Action_preloadAppWall:(NSDictionary *)params;

- (void)Action_showAppWall:(NSDictionary *)params;

@end
