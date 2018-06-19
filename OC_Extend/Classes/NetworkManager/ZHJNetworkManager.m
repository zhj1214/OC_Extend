//
//  ZHJNetworkManager.m
//  testAPP
//
//  Created by 红军张 on 2018/3/27.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import "ZHJNetworkManager.h"
#import "AFNetworking.h"
#import "Tool.h"
#import "MBManager.h"
#import "ZHJNetCacheManger.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

@interface ZHJNetworkManager()

@property (nonatomic,assign) AFNetworkReachabilityStatus workStatus;

@property (strong,nonatomic) NSMutableArray *sessionTaskArr;
// 是否需要 缓存
@property (assign,nonatomic) BOOL isCache;

@end

@implementation ZHJNetworkManager

static ZHJNetworkManager *networkManager = nil;

static AFHTTPSessionManager *_sessionManager;

#pragma mark 创建单利
+(instancetype _Nonnull)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!networkManager) {
            networkManager = [[ZHJNetworkManager alloc] init];
        }
    });
    return networkManager;
}

+(void)initialize {
    //        //无条件的信任服务器上的证书
    //        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    //
    //        // 客户端是否信任非法证书
    //        securityPolicy.allowInvalidCertificates = YES;
    //
    //        // 是否在证书域字段中验证域名
    //        securityPolicy.validatesDomainName = NO;
    
    //        _sessionManager.securityPolicy = securityPolicy;
    
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 打开状态栏的等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // 设置超时时间
    _sessionManager.requestSerializer.timeoutInterval = 25.0;
    // 设置响应内容的类型
    [_sessionManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [_sessionManager.requestSerializer setValue:@"ZwfWiEWrgEFA9A785H12weF7106AJ" forHTTPHeaderField:@"boundary"];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",nil];
}

#pragma mark 初始化，APP每次启动时会调用该方法，运行时不会调用
- (instancetype)init {
    self = [super init];
    if (self) {
        //加载错误信息提示
        self.sessionTaskArr = [NSMutableArray array];
    }
    return self;
}

#pragma mark 设置请求以及相应的序列化器
+ (void)setRequestSerializer:(ZHJRequestSerializer)requestSerializer {
    _sessionManager.requestSerializer = requestSerializer==ZHJRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

#pragma mark 设置返回数据反序列化的格式
+ (void)setResponseSerializer:(ZHJResponseSerializer)responseSerializer {
    _sessionManager.responseSerializer = responseSerializer==ZHJRequestSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}

#pragma mark 设置超时
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time {
    _sessionManager.requestSerializer.timeoutInterval = time;
}

#pragma mark 设置请求头
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

#pragma mark 状态栏的 菊花开关
+ (void)openNetworkActivityIndicator:(BOOL)open {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

#pragma mark 证书校验
- (AFSecurityPolicy*)customSecurityPolicy {
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:_certificatesName ofType:@".cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    NSSet *set = [NSSet setWithObjects:certData, nil];
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    [securityPolicy setPinnedCertificates:set];
    return securityPolicy;
}


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

+(void)stopMonitoring{
    [[AFNetworkReachabilityManager sharedManager]stopMonitoring];
}

#pragma mark 常用网络请求
- (void)sendRequestMethod:(HTTPMethod)requestMethod
                  apiPath:(nonnull NSString *)apiPath
               parameters:(nullable id)parameters
                      hud:(BOOL)isShow
                    cache:(BOOL)cacheBlock
                 progress:(nullable void (^)(NSProgress * _Nullable progress))progress
                  success:(nullable void(^) (BOOL isSuccess, id _Nullable responseObject))success
                  failure:(nullable void(^) (NSString * _Nullable errorMessage))failure {
    WS(weakSelf);
    // 拼接URL
    NSString *requestPath = @"";
    if (self.resourceURL.length >1) {
        requestPath = [NSString stringWithFormat:@"%@%@",self.resourceURL,apiPath];
    } else {
        requestPath = apiPath;
    }
    
    if (cacheBlock) {
        id parameterDic = [parameters mutableCopy];
        [ZHJNetCacheManger getHttpCacheWithURL:requestPath params:parameters withBlock:^(id<NSCoding> object) {
            if (object) {
                [MBManager hideAlert];
                success(YES,object);
                [weakSelf printParamSeting:parameterDic task:nil response:object];
            } else {
                weakSelf.isCache = YES;
                [[ZHJNetworkManager defaultManager] sendRequestMethod:requestMethod apiPath:apiPath parameters:parameters hud:isShow cache:nil progress:progress success:success failure:failure];
            }
        }];
    } else {
        // https SSL验证
        if (self.certificatesName) {
            [_sessionManager setSecurityPolicy:[self customSecurityPolicy]];
        }
        // Loading
        if (isShow) {
            [MBManager showLoading];
        }
        
        NSURLSessionDataTask * httpDataTask = nil;
        switch (requestMethod) {
            case HTTPMethodGET:
            {
                httpDataTask = [_sessionManager GET:requestPath parameters:parameters progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [MBManager hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                    //设置缓存保存缓存数据
                    weakSelf.isCache?[ZHJNetCacheManger setHttpCache:responseObject URL:requestPath params:parameters]:nil;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [MBManager hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
                
            case HTTPMethodPOST:
            {
                httpDataTask = [_sessionManager POST:requestPath parameters:parameters progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [MBManager hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                    //设置缓存保存缓存数据
                    weakSelf.isCache?[ZHJNetCacheManger setHttpCache:responseObject URL:requestPath params:parameters]:nil;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [MBManager hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
                
            case HTTPMethodPUT:
            {
                httpDataTask = [_sessionManager PUT:requestPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [MBManager hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                    //设置缓存保存缓存数据
                    weakSelf.isCache?[ZHJNetCacheManger setHttpCache:responseObject URL:requestPath params:parameters]:nil;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [MBManager hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
                
            case HTTPMethodPATCH:
            {
                httpDataTask = [_sessionManager PATCH:requestPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [MBManager hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                    //设置缓存保存缓存数据
                    weakSelf.isCache?[ZHJNetCacheManger setHttpCache:responseObject URL:requestPath params:parameters]:nil;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [MBManager hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
                
            case HTTPMethodDELETE:
            {
                httpDataTask = [_sessionManager DELETE:requestPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [MBManager hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                    //设置缓存保存缓存数据
                    weakSelf.isCache?[ZHJNetCacheManger setHttpCache:responseObject URL:requestPath params:parameters]:nil;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [MBManager hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
        }
        // 添加sessionTask到数组
        httpDataTask ? [[ZHJNetworkManager defaultManager].sessionTaskArr addObject:httpDataTask] : nil ;
    }
}

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
                                                        failure:(nullable void(^) (NSString  *_Nullable error))failure {
    // 请求的地址
    NSString *requestPath = [serverUrl stringByAppendingPathComponent:apiPath];
    NSURLSessionDataTask * task = nil;
    task = [_sessionManager POST:requestPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSUInteger i = 0 ;
        // 上传图片时，为了用户体验或是考虑到性能需要进行压缩
        for (UIImage * image in imageArray) {
            // 压缩图片，指定宽度（注释：imageCompressed：withdefineWidth：图片压缩的category）
#warning important 这里 忘记写这个方法了
            //            UIImage * resizedImage =  [UIImage imageCompressed:image withdefineWidth:width];
            NSData * imgData = UIImageJPEGRepresentation(image, 0.5);
            // 拼接Data
            [formData appendPartWithFileData:imgData name:[NSString stringWithFormat:@"picflie%ld",(long)i] fileName:@"image.png" mimeType:@" image/jpeg"];
            i++;
        }
        
    } progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success)success(YES,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]);
        
    }];
    return task;
}

#pragma mark 取消所有请求
+ (void)cancelAllRequest {
    // 锁操作
    @synchronized(self) {
        [[ZHJNetworkManager defaultManager].sessionTaskArr enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[ZHJNetworkManager defaultManager].sessionTaskArr  removeAllObjects];
    }
}

#pragma mark 取消指定请求
+ (void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) { return; }
    @synchronized (self) {
        [[ZHJNetworkManager defaultManager].sessionTaskArr  enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[ZHJNetworkManager defaultManager].sessionTaskArr  removeObject:task];
                *stop = YES;
            }
        }];
    }
}

#pragma mark 请求参数打印
-(void)printParamSeting:(NSDictionary*)dic task:( NSURLSessionDataTask * _Nullable )task response:(id)responseObject {
    if (task) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if (dic && response) {
            NSDictionary *dictemp = @{@"URL":response.URL.absoluteString,@"param":dic,@"header":response.allHeaderFields};
            NSLog(@"请求内容:%@",dictemp);
        }
    }
    if (!task && dic) {
        NSLog(@"请求内容:%@",dic);
    }
    if (responseObject) {
        NSLog(@"response:%@",responseObject);
    }
}

#pragma mark 报错信息
/**
 处理报错信息
 
 @param error AFN返回的错误信息
 @param task 任务
 @return description
 */
- (NSString *)failHandleWithErrorResponse:( NSError * _Nullable )error ParamSeting:(NSDictionary*)dic task:( NSURLSessionDataTask * _Nullable )task {
    __block NSString *message = nil;
    // 打印请求 参数
    [self printParamSeting:dic task:task response:nil];
    // 这里可以直接设定错误反馈，也可以利用AFN 的error信息直接解析展示
    NSData *afNetworking_errorMsg = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSLog(@"afNetworking_错误信息:/n %@",[[NSString alloc]initWithData:afNetworking_errorMsg encoding:NSUTF8StringEncoding]);
    if (!afNetworking_errorMsg) {
        message = @"网络连接失败";
    }
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    NSInteger responseStatue = response.statusCode;
    if (responseStatue >= 500) {  // 网络错误
        message = @"服务器维护升级中,请耐心等待";
    } else if (responseStatue >= 400) {
        if (afNetworking_errorMsg) {
            // 错误信息
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:afNetworking_errorMsg options:NSJSONReadingAllowFragments error:nil];
            message = responseObject[@"error"];
        }
    }
    NSLog(@"错误信息：\n %@",error);
    return message;
}

@end

#pragma mark - NSDictionary,NSArray的分类
/*
 *新建NSDictionary与NSArray的分类, 控制台打印json数据中的中文
 */
#ifdef DEBUG
@implementation NSArray (ZJ)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    [strM appendString:@")"];
    
    return strM;
}

@end

@implementation NSDictionary (ZJ)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    
    [strM appendString:@"}\n"];
    
    return strM;
}
@end
#endif

