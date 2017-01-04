//
//  Target_Admob.h
//  ZFNativeAdsManagerDemo
//
//  Created by Jason on 17/1/4.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target_Admob : NSObject

- (void)Action_setDelegate:(NSDictionary *)params;
- (void)Action_startAdmobWithAdUnitId:(NSDictionary *)params;
- (void)Action_showAdmobFromRootViewController:(NSDictionary *)params;

@end
