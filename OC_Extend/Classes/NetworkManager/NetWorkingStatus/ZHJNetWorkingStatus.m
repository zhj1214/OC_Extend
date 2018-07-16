//
//  ZHJNetWorkingStatus.m
//  NetWorking
//
//  Created by 红军张 on 2018/7/5.
//  Copyright © 2018年 红军张. All rights reserved.
//

#import "ZHJNetWorkingStatus.h"
#import <AFNetworking/AFNetworking.h>
#import "ZHJNetworkManager.h"
#import "LogManager.h"

@implementation ZHJNetWorkingStatus

#pragma mark 监听网络状态
+ (void)startMonitoring:(void(^)(BOOL isNet))netBlock {
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [ZHJNetworkManager defaultManager].workStatus = status;
        if (status == AFNetworkReachabilityStatusNotReachable) {
            //跳转到设置URL的地方
            netBlock(NO);
        }else{
            netBlock(YES);
        }
    }];
}

+(void)stopMonitoring {
    ZHJLog([LogManager getClassForCoderName:self],@"停止网络状态监听");
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
}

@end
