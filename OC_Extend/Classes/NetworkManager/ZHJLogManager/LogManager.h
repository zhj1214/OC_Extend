//
//  LogManager.h
//  testAPP
//
//  Created by 红军张 on 2018/4/17.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import <Foundation/Foundation.h>

// 记录本地日志
#define ZHJLog(module,...) [[LogManager sharedInstance] logInfo:module logStr:__VA_ARGS__,nil]

typedef void (^BoolBlock)(BOOL isok);

typedef void (^ErrorBlock)(NSString *error);

@interface LogManager : NSObject

/**
 *  获取单例实例
 *
 *  @return 单例实例
 */
+ (instancetype) sharedInstance;

/**
 *  写入日志
 *
 *  @param module 模块名称
 *  @param logStr 日志信息,动态参数
 */
- (void)logInfo:(NSString*)module logStr:(NSString*)logStr, ...;

/**
 *  清空过期的日志
 */
- (void)clearExpiredLog;

/**
 *  检测日志是否需要上传
 */
- (void)checkLogNeedUpload;

/**
 *  返回当前类名字
 */
+(NSString*)getClassForCoderName:(id)currentClass;

/**
 字典转json

 @param dict 字典
 @return json字符串
 */
+(NSString *)convertToJsonData:(NSDictionary *)dict;
@end
