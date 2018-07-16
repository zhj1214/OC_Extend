//
//  ZHJRequestConfig.h
//  NetWorking
//
//  Created by 红军张 on 2018/7/5.
//  Copyright © 2018年 红军张. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 请求类型
 
 - RequestMethod_Get: 获取资源，不会改动资源
 - RequestMethod_Post: 创建记录
 - RequestMethod_Put: 更新全部属性
 - RequestMethod_Delete: 删除资源
 - RequestMethod_Patch: 改变资源状态或更新部分属性
 
 */
typedef NS_ENUM(NSInteger, RequestMethod) {
    RequestMethod_Get = 0,
    RequestMethod_Post,
    RequestMethod_Put,
    RequestMethod_Patch,
    RequestMethod_Delete
};

@interface ZHJRequestConfig : NSObject

/**
 最终的请求URL 包含了自定义的 参数
 */
@property (readonly,nonatomic,copy) NSURL *url;

/**
 路径
 */
@property (readonly,nonatomic,copy) NSString *path;

/**
 拼接好的URL地址
 */
@property (readonly,nonatomic,copy) NSString *fullPath;

/**
 参数
 */
@property (readonly,nonatomic,copy) NSDictionary *parameters;

/**
 请求上传，上传数据data
 */
@property (readonly,nonatomic,copy) NSData *data;

/**
 请求方式
 */
@property (readonly,nonatomic)RequestMethod methodType;

#pragma mark -- optional

/**
 请求 host
 */
@property (nonatomic,retain) NSString *baseUrl;

/**
 设置HTTPS请求时的SSL证书，设置一次就可以了
 */
@property (nonatomic,copy)NSString *certificatesName;

/**
 设置请求超时时间:默认为30S
 */
@property (nonatomic,assign)NSTimeInterval timeoutInterval;

/**
 请求 tag
 */
@property (nonatomic,retain)NSString *tag;

/**
 请求 自定义参数token
 */
@property (nonatomic,retain) NSString *token;

/**
 请求
 */
@property (nonatomic,retain) NSString *sig;

/**
 请求 自定义参数 时间戳
 */
@property (nonatomic,retain) NSString *timestamp;

/**
 是否显示Loding
 */
@property (nonatomic,assign) BOOL hudIsShow;

/**
 是否缓存
 */
@property (nonatomic,assign) BOOL isCache;


#pragma mark -- ClassFuntion
/**
 初始化 Request对象
 
 @param methodType 请求类型
 @param path url地址
 @param paramDic 参数
 @return 返回Request对象
 */
+ (instancetype)sharedRequestWithMethodType:(RequestMethod)methodType withPath:(NSString *)path withParam:(NSDictionary *)paramDic;

/**
 上传
 
 @param data 上传数据
 @param path 上传地址
 @param paramDic 上传参数
 @param config 配置文件
 @return 返回Request对象
 */
+ (instancetype)sharedRequestWithData:(NSData *)data withPath:(NSString *)path withParam:(NSDictionary *)paramDic withConfig:(ZHJRequestConfig *)config;

@end
