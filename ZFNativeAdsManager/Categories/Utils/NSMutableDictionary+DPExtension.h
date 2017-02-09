//
//  NSMutableDictionary+DPExtension.h
//  ZFNativeAdsManagerDemo
//
//  Created by DaiPei on 2017/2/9.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (DPExtension)

- (void)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
