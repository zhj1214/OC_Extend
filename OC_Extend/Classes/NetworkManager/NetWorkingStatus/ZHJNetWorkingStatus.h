//
//  ZHJNetWorkingStatus.h
//  NetWorking
//
//  Created by 红军张 on 2018/7/5.
//  Copyright © 2018年 红军张. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHJNetWorkingStatus : NSObject

/*
 * 开启网络监测 YES 有网络  NO 没有联网
 */
+ (void)startMonitoring:(void(^)(BOOL isNet))netBlock;

/*
 * 关闭网络监测
 */
+ (void)stopMonitoring;

@end
