//
//  NSMutableDictionary+DPExtension.m
//  ZFNativeAdsManagerDemo
//
//  Created by DaiPei on 2017/2/9.
//  Copyright © 2017年 Ruozi. All rights reserved.
//

#import "NSMutableDictionary+DPExtension.h"

@implementation NSMutableDictionary (safe)

- (void)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!aKey) {
        return ;
    }
    if (!anObject) {
        [self removeObjectForKey:aKey];
    }
    else {
        [self setObject:anObject forKey:aKey];
    }
}

@end
