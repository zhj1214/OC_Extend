//
//  XMNetWorkHelper.h
//  ZBtest
//
//  Created by 红军张 on 2018/3/19.
//  Copyright © 2018年 ZBtest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define ValidationIdentityURL @"https://cloudapi.linkface.cn/identity/liveness_idnumber_verification"
#define IdentitySDK_Version @"identitySDK_0.07_180417_T"

typedef void (^XMCompletioBlock)(NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^XMSuccessBlock)(NSDictionary *data);
typedef void (^XMFailureBlock)(NSError *error);

@interface XMNetWorkHelper : NSObject

/**
 *  get请求
 */
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;

/**
 * post请求
 */
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;
/**
 * post 表单
 */
+ (void)postMultipartFormWithUrlString:(NSString *)kDetectUrl parameters:(id)parameters data:(NSData*)fileData success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;

@end


