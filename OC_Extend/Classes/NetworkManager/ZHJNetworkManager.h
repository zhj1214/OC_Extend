//
//  ZHJNetworkManager.h
//  testAPP
//
//  Created by 红军张 on 2018/3/27.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define ValidationIdentityURL @"https://cloudapi.linkface.cn/identity/liveness_idnumber_verification"

/**
 * GET：获取资源，不会改动资源
 * POST：创建记录
 * PATCH：改变资源状态或更新部分属性
 * PUT：更新全部属性
 * DELETE：删除资源
 */
typedef NS_ENUM(NSUInteger, HTTPMethod) {
    HTTPMethodGET,
    HTTPMethodPOST,
    HTTPMethodPUT,
    HTTPMethodPATCH,
    HTTPMethodDELETE,
};

@interface ZHJNetworkManager : NSObject

/**
 *  单例
 *
 *  @return 网络请求类的实例
 */
+(instancetype _Nonnull)defaultManager;

#pragma mark 常用网络请求方式
/**
 常用网络请求方式
 
 @param requestMethod 请求方试
 @param apiPath 方法的链接
 @param parameters 参数
 @param progress 进度
 @param success 成功
 @param failure 失败
 @return return value description
 */

- (nullable NSURLSessionDataTask *)sendRequestMethod:(HTTPMethod)requestMethod
                                             apiPath:(nonnull NSString *)apiPath
                                          parameters:(nullable id)parameters
                                            progress:(nullable void (^)(NSProgress * _Nullable progress))progress
                                             success:(nullable void(^) (BOOL isSuccess, id _Nullable responseObject))success
                                             failure:(nullable void(^) (NSString * _Nullable errorMessage))failure ;
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

/**
 异常上报
 
 @param errorInfo 异常信息
 */
-(void)reportDevicesErrorInfo:(NSString*)errorInfo;
@end