//
//  ZHJNetworkManager.h
//  testAPP
//
//  Created by 红军张 on 2018/3/27.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ZHJRequestConfig.h"

#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;

/**上传文件成功之后的回调 */
typedef void(^UploadMyFileSuccess)(id dataResource);

/** 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小*/
typedef void (^HttpProgress)(NSProgress *progress);

typedef NS_ENUM(NSUInteger, ZHJRequestSerializer) {
    /** 设置请求数据为JSON格式*/
    ZHJRequestSerializerJSON = 1,
    /** 设置请求数据为二进制格式*/
    ZHJRequestSerializerHTTP = 2,
};

typedef NS_ENUM(NSUInteger, ZHJResponseSerializer) {
    /** 设置响应数据为JSON格式*/
    ZHJResponseSerializerJSON = 1,
    /** 设置响应数据为二进制格式*/
    ZHJResponseSerializerHTTP = 2,
};

@interface ZHJNetworkManager : NSObject

@property (nonatomic,assign) AFNetworkReachabilityStatus workStatus;

/**
 *  单例
 *
 *  @return 网络请求类的实例
 */
+(instancetype _Nonnull)defaultManager;

/**
 *  设置网络请求参数的格式:默认为二进制格式
 *
 *  @param requestSerializer ZHJRequestSerializerJSON(JSON格式),ZHJRequestSerializerHTTP(二进制格式),
 */
+ (void)setRequestSerializer:(ZHJRequestSerializer)requestSerializer;

/**
 *  设置服务器响应数据格式:默认为JSON格式
 *
 *  @param responseSerializer ZHJResponseSerializerJSON(JSON格式),ZHJResponseSerializerHTTP(二进制格式)
 */
+ (void)setResponseSerializer:(ZHJResponseSerializer)responseSerializer;

/**
 *  设置请求头
 */
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 *  是否打开网络状态转圈菊花:默认打开
 *
 *  @param open YES(打开), NO(关闭)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;

/**
 取消所有请求
 */
+ (void)cancelAllRequest;

/**
 取消指定请求

 @param URL 地址
 */
+ (void)cancelRequestWithURL:(NSString *)URL;

/**
 常用网络请求方式

 @param Config 请求配置文件
 @param progress 进度
 @param success 成功
 @param failure 失败
 */
- (void)sendRequestMethod:(ZHJRequestConfig*)Config
                 progress:(nullable void (^)(NSProgress * _Nullable progress, NSString *tag))progress
                  success:(nullable void(^) (BOOL isSuccess, id _Nullable responseObject))success
                  failure:(nullable void(^) (NSString * _Nullable errorMessage))failure;

/**
 下载文件

 @param URL 下载地址
 @param fileDir 存储路径
 @param progress 下载进度
 @param success 成功
 @param failure 失败
 @return 下载任务
 */
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                             progress:(HttpProgress)progress
                              success:(void(^)(NSString *))success
                              failure:(nullable void(^) (NSString  *_Nullable error))failure;

/**
 表单上传

 @param block formdata数据
 @param progress 进度
 @param success 成功
 @param failure 失败
 @return 任务对象
 */
- (nullable NSURLSessionDataTask *)sendPOSTRequestWithserverUrl:(ZHJRequestConfig*)Config
                                      constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                                       progress:(nullable void (^)(NSProgress * _Nullable progress))progress
                                                        success:(nullable void(^) (BOOL isSuccess, id _Nullable responseObject))success
                                                        failure:(nullable void(^) (NSString  *_Nullable error))failure;

/**
 上传图片
 
 @param serverUrl 服务器地址
 @param apiPath 方法的链接
 @param parameters 参数
 @param imageArray 图片
 @param width 图片宽度
 @param progress 进度
 @param success 成功
 @param failure 失败
 @return return value description
 */
- (nullable NSURLSessionDataTask *)sendPOSTRequestWithserverUrl:(nonnull NSString *)serverUrl
                                                        apiPath:(nonnull NSString *)apiPath
                                                     parameters:(nullable id)parameters
                                                     imageArray:(NSArray *_Nullable)imageArray
                                                    targetWidth:(CGFloat )width
                                                       progress:(nullable void (^)(NSProgress * _Nullable progress))progress
                                                        success:(nullable void(^) (BOOL isSuccess, id _Nullable responseObject))success
                                                        failure:(nullable void(^) (NSString *_Nullable error))failure ;

@end
