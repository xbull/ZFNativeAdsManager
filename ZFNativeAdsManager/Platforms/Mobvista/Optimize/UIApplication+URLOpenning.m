//
//  UIApplication+URLOpenning.m
//  MVSDKDemo
//
//  Created by Dai Pei on 2017/1/10.
//  Copyright © 2017年 Dai Pei. All rights reserved.
//

#import "UIApplication+URLOpenning.h"
#import "NSObject+DPExtension.h"

@implementation UIApplication (URLOpenning)

static NSString *forbidURLStr;

+ (void)load {
    
    forbidURLStr = nil;
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(openURL:options:completionHandler:) swizzledSelector:@selector(dp_openURL:options:completionHandler:)];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(openURL:) swizzledSelector:@selector(dp_openURL:)];
    
}

+ (void)disallowURLStr:(NSString *)URLStr {
    forbidURLStr = URLStr;
}

- (void)dp_openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion {
    
    if (forbidURLStr && [[url absoluteString] isEqualToString:forbidURLStr]) {
        NSLog(@"【ZFMobvistaNativeAdsManager】forbid:%@", url);
        forbidURLStr = nil;
        return ;
    }
    [self dp_openURL:url options:options completionHandler:completion];
}

- (BOOL)dp_openURL:(NSURL*)url {
    
    if (forbidURLStr && [[url absoluteString] isEqualToString:forbidURLStr]) {
        NSLog(@"【ZFMobvistaNativeAdsManager】forbid:%@", url);
        forbidURLStr = nil;
        return YES;
    }
    return [self dp_openURL:url];
    
    return YES;
}


@end
