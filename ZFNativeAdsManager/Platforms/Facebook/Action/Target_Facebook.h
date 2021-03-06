//
//  Target_Facebook.h
//  ZFNativeAdsManagerDemo
//
//  Created by Ruozi on 12/17/16.
//  Copyright © 2016 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target_Facebook : NSObject

- (void)Action_setDelegate:(NSDictionary *)params;

- (void)Action_configurePlacementInfo:(NSDictionary *)params;

- (void)Action_loadNativeAds:(NSDictionary *)params;

- (id)Action_fetchNativeAd:(NSDictionary *)params;

- (void)Action_registerAdInteraction:(NSDictionary *)params;

- (void)Action_setDebugLogEnable:(NSDictionary *)params;

- (id)Action_fetchAdChoiceView:(NSDictionary *)params;

@end
