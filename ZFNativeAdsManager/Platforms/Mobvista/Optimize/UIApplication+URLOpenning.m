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

//static NSString *forbidURLStr;
static NSMutableArray<NSString *> *forbidURLStrArray;
static NSUInteger forbidURLCount;

+ (void)load {
    
//    forbidURLStr = nil;
    forbidURLCount = 5;
    forbidURLStrArray = [NSMutableArray arrayWithCapacity:forbidURLCount];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(openURL:options:completionHandler:) swizzledSelector:@selector(dp_openURL:options:completionHandler:)];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(openURL:) swizzledSelector:@selector(dp_openURL:)];
    
}

+ (void)disallowURLStr:(NSString *)URLStr {
    if (!forbidURLStrArray) {
        forbidURLStrArray = [NSMutableArray arrayWithCapacity:forbidURLCount];
    }
    if (forbidURLStrArray.count >= forbidURLCount) {
        [forbidURLStrArray removeObjectAtIndex:0];
    }
    [forbidURLStrArray addObject:URLStr];
    NSLog(@"【ZFMobvistaNativeAdsManager】the forbid url pool:%@", forbidURLStrArray);
}

- (void)dp_openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion {
    
//    if (forbidURLStr && [[url absoluteString] isEqualToString:forbidURLStr]) {
//        NSLog(@"【ZFMobvistaNativeAdsManager】forbid:%@", url);
//        forbidURLStr = nil;
//        return ;
//    }
    if (forbidURLStrArray) {
        for (NSString *urlStr in forbidURLStrArray) {
            if ([urlStr isEqualToString:[url absoluteString]]) {
                NSLog(@"【ZFMobvistaNativeAdsManager】forbid2:%@", url);
                return ;
            }
        }
    }
    NSLog(@"【ZFMobvistaNativeAdsManager】dp_open url2:%@", url);
    [self dp_openURL:url options:options completionHandler:completion];
}

- (BOOL)dp_openURL:(NSURL*)url {
    
//    if (forbidURLStr && [[url absoluteString] isEqualToString:forbidURLStr]) {
//        NSLog(@"【ZFMobvistaNativeAdsManager】forbid:%@", url);
//        forbidURLStr = nil;
//        return YES;
//    }
    
    if (forbidURLStrArray) {
        for (NSString *urlStr in forbidURLStrArray) {
            if ([urlStr isEqualToString:[url absoluteString]]) {
                NSLog(@"【ZFMobvistaNativeAdsManager】forbid1:%@", url);
                return YES;
            }
        }
    }
    NSLog(@"【ZFMobvistaNativeAdsManager】dp_open url1:%@", url);
    return [self dp_openURL:url];
    
}


@end
