//
//  NSObject+DPExtension.m
//  DPCategoryDemo
//
//  Created by Dai Pei on 2016/12/14.
//  Copyright © 2016年 Dai Pei. All rights reserved.
//

#import "NSObject+DPExtension.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzling)

+ (void)intanceMethodExchangeWithOriginSelector:(SEL)sel1 swizzledSelector:(SEL)sel2 {
    
    Class class = [self class];
    
    if (![class instancesRespondToSelector:sel1] || ![class instancesRespondToSelector:sel2]) {
        return ;
    }
    
    Method method1 = class_getInstanceMethod(class, sel1);
    Method method2 = class_getInstanceMethod(class, sel2);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    sel1,
                    method_getImplementation(method2),
                    method_getTypeEncoding(method2));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            sel2,
                            method_getImplementation(method1),
                            method_getTypeEncoding(method1));
    } else {
        method_exchangeImplementations(method1, method2);
    }
}

@end
