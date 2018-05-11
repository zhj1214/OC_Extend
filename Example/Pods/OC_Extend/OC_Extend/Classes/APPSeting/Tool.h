//
//  Tool.h
//  testAPP
//
//  Created by 红军张 on 2018/3/26.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject

/**
 异步执行代码块
 
 @param mainTask 执行操作
 */
+(void)async:(void (^)(void))mainTask;

/**
 异步执行代码块（先非主线程执行，再返回主线程执行）
 
 @param backgroundTask 执行操作
 @param mainTask 执行操作
 */
+(void)async:(void (^)(id ii))backgroundTask mainTask:(void (^)(id i))mainTask;

/**
 回到主线程
 
 @param mainTask 执行操作
 */
+(void)getMainQueu:(void (^)(void))mainTask;

/**
 获取手机设备信息
 @return 手机基本json信息
 */
+(NSString*)getPhoneDeviceInfo;

/**
 字典转换json
 
 @param dict 字典
 @return json字典结果
 */
+(NSString *)convertToJsonData:(NSDictionary *)dict;

/**
 sha1 散列哈希值
 
 @param input 字符串
 @return sha1结果
 */
+(NSString *)signWithSHA1:(NSString *)input;

/**
 获取手机ip
 
 @return 网络ip
 */
+(NSString *)getIPAddress;

/**
 获取手机Bundle ID
 
 @return Bundle ID
 */
+(NSString*)getSDKApplicationID;

/**
 获取手机系统版本号
 
 @return 版本号
 */
+(NSString*)getSystemVersion;

/**
 获取手机UUID
 
 @return UUID
 */
+(NSString *)getUserUUID;

/**
 将信息保存到keychain
 
 @return YES = success
 */
+(BOOL)saveKeychaininfo:(NSString *)secret key:(NSString*)key;

/**
 读取keychain信息
 
 @return info
 */
+(NSString*)takeKeychaininfoKey:(NSString*)key;

/**
 获取当前时间
 
 @return 当前年月日时分秒
 */
+(NSString*)getCurrentTimes;

/**
 获取当前时间戳
 
 @return 毫秒
 */
+(NSString *)getNowTimeTimestamp;

@end

