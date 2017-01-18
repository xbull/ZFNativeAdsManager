//
//  UIApplication+URLOpenning.m
//  MVSDKDemo
//
//  Created by Dai Pei on 2017/1/10.
//  Copyright © 2017年 Dai Pei. All rights reserved.
//

#import "UIApplication+URLOpenning.h"
#import "NSObject+DPExtension.h"

#define MaxForbidURLCount       5
#define MaxAllowedURLCount      5

@implementation UIApplication (URLOpenning)

static NSMutableArray<NSString *> *forbidURLStrPool;
static NSMutableArray<NSString *> *allowedURLStrPool;

+ (void)load {
    
    forbidURLStrPool = [NSMutableArray arrayWithCapacity:MaxForbidURLCount];
    allowedURLStrPool = [NSMutableArray arrayWithCapacity:MaxAllowedURLCount];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(openURL:options:completionHandler:) swizzledSelector:@selector(dp_openURL:options:completionHandler:)];
    
    [UIApplication intanceMethodExchangeWithOriginSelector:@selector(openURL:) swizzledSelector:@selector(dp_openURL:)];
    
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
    NSLog(@"【ZFMobvistaNativeAdsManager】the forbid url pool:%@", forbidURLStrPool);
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
    NSLog(@"【ZFMobvistaNativeAdsManager】the allowed url pool:%@", allowedURLStrPool);
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
                        NSLog(@"【ZFMobvistaNativeAdsManager】allow2:%@", url);
                        return [self dp_openURL:url options:options completionHandler:completion];
                    }
                }
                NSLog(@"【ZFMobvistaNativeAdsManager】forbid2:%@", url);
                return ;
            }
        }
    }
    NSLog(@"【ZFMobvistaNativeAdsManager】dp_open url2:%@", url);
    [self dp_openURL:url options:options completionHandler:completion];
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
                        NSLog(@"【ZFMobvistaNativeAdsManager】allow1:%@", url);
                        return [self dp_openURL:url];
                    }
                    
                }
                NSLog(@"【ZFMobvistaNativeAdsManager】forbid1:%@", url);
                return YES;
            }
        }
    }
    NSLog(@"【ZFMobvistaNativeAdsManager】dp_open url1:%@", url);
    return [self dp_openURL:url];
    
}


@end
