//
//  UIApplication+URLOpenning.m
//  MVSDKDemo
//
//  Created by Dai Pei on 2017/1/10.
//  Copyright © 2017年 Dai Pei. All rights reserved.
//

#import "UIApplication+URLOpenning.h"
#import "NSObject+DPExtension.h"
#import "ZFNativeAdsManager.h"

#define MaxForbidURLCount       5
#define MaxAllowedURLCount      5

@implementation UIApplication (URLOpenning)

static NSMutableArray<NSString *> *forbidURLStrPool;
static NSMutableArray<NSString *> *allowedURLStrPool;
static BOOL debugLogEnable;

+ (void)load {
    
    forbidURLStrPool = [NSMutableArray arrayWithCapacity:MaxForbidURLCount];
    allowedURLStrPool = [NSMutableArray arrayWithCapacity:MaxAllowedURLCount];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(openURL:options:completionHandler:) swizzledSelector:@selector(dp_openURL:options:completionHandler:)];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(dp_openURL:options:completionHandler:) swizzledSelector:@selector(real_openURL:options:completionHandler:)];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(openURL:) swizzledSelector:@selector(dp_openURL:)];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(dp_openURL:) swizzledSelector:@selector(real_openURL:)];
    
}

+ (void)disallowURLStr:(NSString *)URLStr {
    if (!forbidURLStrPool) {
        forbidURLStrPool = [NSMutableArray arrayWithCapacity:MaxForbidURLCount];
    }
    if (forbidURLStrPool.count >= MaxForbidURLCount) {
        [forbidURLStrPool removeObjectAtIndex:0];
    }
    if (URLStr) {
        [forbidURLStrPool addObject:URLStr];
    }
    if (debugLogEnable) {
        NSLog(@"【ZFMobvistaNativeAdsManager】the forbid url pool:%@", forbidURLStrPool);
    }
}

+ (void)allowURLStr:(NSString *)URLStr {
    if (!allowedURLStrPool) {
        allowedURLStrPool = [NSMutableArray arrayWithCapacity:MaxAllowedURLCount];
    }
    if (allowedURLStrPool.count >= MaxAllowedURLCount) {
        [allowedURLStrPool removeObjectAtIndex:0];
    }
    if (URLStr) {
        [allowedURLStrPool addObject:URLStr];
    }
    if (debugLogEnable) {
        NSLog(@"【ZFMobvistaNativeAdsManager】the allowed url pool:%@", allowedURLStrPool);
    }
}

+ (void)setURLOpenningDebugLogEnable:(BOOL)enable {
    debugLogEnable = enable;
}

- (void)dp_openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion {
    
    if (forbidURLStrPool) {
        for (int i = 0; i < forbidURLStrPool.count; i++) {
            
            NSString *urlStr = forbidURLStrPool[i];
            if ([urlStr isEqualToString:[url absoluteString]]) {
                
                [forbidURLStrPool removeObjectAtIndex:i];
                for (int j = 0; j < allowedURLStrPool.count; j++) {
                    
                    NSString *allowedURLStr = allowedURLStrPool[j];
                    
                    if ([allowedURLStr isEqualToString:[url absoluteString]]) {
                        
                        [allowedURLStrPool removeObjectAtIndex:j];
                        [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】allow2:%@", url]];
                        return [self real_openURL:url options:options completionHandler:completion];
                    }
                }
                [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】forbid2:%@", url]];
                return ;
            }
        }
    }
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】dp_open url2:%@", url]];
    [self real_openURL:url options:options completionHandler:completion];
}

- (BOOL)dp_openURL:(NSURL*)url {
    
    if (forbidURLStrPool) {
        for (int i = 0; i < forbidURLStrPool.count; i++) {
            
            NSString *urlStr = forbidURLStrPool[i];
            if ([urlStr isEqualToString:[url absoluteString]]) {
                
                [forbidURLStrPool removeObjectAtIndex:i];
                for (int j = 0; j < allowedURLStrPool.count; j++) {
                    
                    NSString *allowedURLStr = allowedURLStrPool[j];
                    
                    if ([allowedURLStr isEqualToString:[url absoluteString]]) {
                        
                        [allowedURLStrPool removeObjectAtIndex:j];
                        [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】allow1:%@", url]];
                        return [self real_openURL:url];
                    }
                    
                }
                [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】forbid1:%@", url]];
                return YES;
            }
        }
    }
    [self printDebugLog:[NSString stringWithFormat:@"【ZFMobvistaNativeAdsManager】dp_open url1:%@", url]];
    return [self real_openURL:url];
    
}

- (void)printDebugLog:(NSString *)debugLog {
    if (debugLogEnable) {
        NSLog(@"%@", debugLog);
    }
}

//the method(real_openURL:options:completionHandler:)'s implementation is "openURL:options:completionHandler:"

- (void)real_openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion {
    
}

//the method(real_openURL:)'s implementation is "openURL:"

- (BOOL)real_openURL:(NSURL*)url {
    
    return YES;
}


@end
