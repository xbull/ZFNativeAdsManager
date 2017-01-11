//
//  NSObject+DPExtension.h
//  DPCategoryDemo
//
//  Created by Dai Pei on 2016/12/14.
//  Copyright © 2016年 Dai Pei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizzling)

+ (void)intanceMethodExchangeWithOriginSelector:(SEL)sel1 swizzledSelector:(SEL)sel2;

@end
