//
//  ZHJNetworkManager.h
//  testAPP
//
//  Created by 红军张 on 2018/3/27.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;

///**请求成功的回调 */
//typedef void(^RequestSuccessBlock)(id responseObject);
//
///**请求失败的回调 */
//typedef void(^RequestFailBlock)(NSString *errorStr);

/** 缓存的Block */
//typedef void(^RequestCache)(id responseCache);

/**上传文件成功之后的回调 */
typedef void(^UploadMyFileSuccess)(id dataResource);

/** 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小*/
typedef void (^HttpProgress)(NSProgress *progress);

/**
 * GET：获取资源，不会改动资源
 * POST：创建记录
 * PATCH：改变资源状态或更新部分属性
 * PUT：更新全部属性
 * DELETE：删除资源
 */
typedef NS_ENUM(NSUInteger, HTTPMethod) {
    HTTPMethodGET   = 1,
    HTTPMethodPOST  = 2,
    HTTPMethodPUT   = 3,
    HTTPMethodPATCH = 4,
    HTTPMethodDELETE= 5,
};

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

/**
 设置网络请求的前缀,在delegate中设置一次就可以，也可以根据测试版和正式版分别设置
 */
@property (nonatomic,copy)NSString *resourceURL;

/**
 设置HTTPS请求时的SSL证书，设置一次就可以了
 */
@property (nonatomic,copy)NSString *certificatesName;

/**
 *  单例
 *
 *  @return 网络请求类的实例
 */
+(instancetype _Nonnull)defaultManager;

/*
 * 开启网络监测 YES 有网络  NO 没有联网
 */
+ (void)startMonitoring:(void(^)(BOOL isNet))netBlock;

/*
 * 关闭网络监测
 */
+ (void)stopMonitoring;


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
 *  设置请求超时时间:默认为30S
 *
 *  @param time 时长
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

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

#pragma mark 常用网络请求方式
/**
 常用网络请求方式
 
 @param requestMethod   请求方试
 @param apiPath         方法的链接
 @param parameters      参数
 @param isShow          是否显示Loading
 @param cacheBlock      是否缓存
 @param progress        进度
 @param success         成功
 @param failure         失败
 */

- (void)sendRequestMethod:(HTTPMethod)requestMethod
                  apiPath:(nonnull NSString *)apiPath
               parameters:(nullable id)parameters
                      hud:(BOOL)isShow
                    cache:(BOOL)cacheBlock
                 progress:(nullable void (^)(NSProgress * _Nullable progress))progress
                  success:(nullable void(^) (BOOL isSuccess, id _Nullable responseObject))success
                  failure:(nullable void(^) (NSString * _Nullable errorMessage))failure;

#pragma mark POST 上传图片
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
