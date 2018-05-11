//
//  ConfusionCoding.h
//  encryptionTest
//
//  Created by 红军张 on 2018/4/13.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import <Foundation/Foundation.h>

// 初始化回调
typedef void (^Success)(BOOL isSuccess, NSString *errorInfo);

@interface ConfusionCoding : NSObject

/**
 初始化SDK
 
 @param dictionary 包含：user-indentify、app-user、sign、cert、token、date 信息
 @param coding YES：混淆编码， NO：解混淆
 @param block 混淆结果
 */
+(void)initCommunicationStrengthenSDK:(NSDictionary*)dictionary callBack:(Success)block;

/**
 数值 混淆/解混淆
 
 @param dic 要混淆的字段
 @param coding YES：混淆编码， NO：解混淆
 @return 混淆结果
 */
+(NSMutableDictionary*)getMixToNumberData:(NSMutableDictionary*)dic isCoding:(BOOL)coding;
/**
 字符串 混淆 解混淆
 
 @param dic 要混淆的字段
 @param coding YES：混淆编码， NO：解混淆
 @return 混淆结果
 */
+(NSMutableDictionary*)getMixToStringData:(NSMutableDictionary*)dic isCoding:(BOOL)coding;

@end





