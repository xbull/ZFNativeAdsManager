//
//  NSMutableDictionary+DPExtension.m
//  ZFNativeAdsManagerDemo
//
//  Created by DaiPei on 2017/2/9.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "NSMutableDictionary+DPExtension.h"

@implementation NSMutableDictionary (DPExtension)

- (void)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
