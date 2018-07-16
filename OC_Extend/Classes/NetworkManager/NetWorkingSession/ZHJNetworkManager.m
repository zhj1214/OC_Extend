//
//  ZHJNetworkManager.m
//  testAPP
//
//  Created by 红军张 on 2018/3/27.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import "ZHJNetworkManager.h"
#import "MBManager.h"
#import "ZHJNetCacheManger.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "LogManager.h"
//#import "CustomHTTPProtocol.h"

@interface ZHJNetworkManager()

@property (strong,nonatomic) NSMutableArray *sessionTaskArr;
/**
 是否需要 缓存
 */
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
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置超时时间
    _sessionManager.requestSerializer.timeoutInterval = 20.0;
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
    ZHJLog([LogManager getClassForCoderName:self],@"设置网络超时时间：",[NSString stringWithFormat:@"%f秒",time]);
    _sessionManager.requestSerializer.timeoutInterval = time;
}

#pragma mark 设置请求头
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
    ZHJLog([LogManager getClassForCoderName:self],@"设置请求头：",_sessionManager.requestSerializer);
}

#pragma mark 状态栏的 菊花开关
+ (void)openNetworkActivityIndicator:(BOOL)open {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

#pragma mark 证书校验
- (AFSecurityPolicy*)customSecurityPolicy:(NSString*)certificatesName {
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:certificatesName ofType:@".cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    NSSet *set = [NSSet setWithObjects:certData, nil];
    // 通过指定的验证策略`AFSSLPinningMode` AFSSLPinningModeCertificate 创建证书验证模式
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

#pragma mark 常用网络请求
- (void)sendRequestMethod:(ZHJRequestConfig*)Config
                 progress:(nullable void (^)(NSProgress * _Nullable progress, NSString *tag))progress
                  success:(nullable void(^) (BOOL isSuccess, id _Nullable responseObject))success
                  failure:(nullable void(^) (NSString * _Nullable errorMessage))failure {
    WS(weakSelf);
    [ZHJNetworkManager openNetworkActivityIndicator:YES];
    //     设置超时时间
    if (Config.timeoutInterval != 20 ) {
        [ZHJNetworkManager setRequestTimeoutInterval:Config.timeoutInterval];
    }
    
    // Loading
    if (Config.hudIsShow) {
        [MBManager showLoading];
    }
    
    // 拼接URL
    NSString *requestPath = Config.url.absoluteString;
    if (![requestPath hasPrefix:@"http"]) {
        return [MBManager showBriefAlert:@"请求地址不存在"];
    } else {
        if (![requestPath containsString:Config.baseUrl]) {
            requestPath = [requestPath substringFromIndex:(Config.url.absoluteString.length - Config.path.length)];
            requestPath = [NSString stringWithFormat:@"%@%@",Config.baseUrl,requestPath];
        }
    }
    
    // 参数
    __block NSDictionary *parameters = [Config.parameters mutableCopy];
    
    // 是否 缓存
    if (Config.isCache) {
        id parameterDic = [parameters mutableCopy];
        id object = [[ZHJNetCacheManger sharedManager] getCacheDataWithUrl:Config.fullPath];
        if (object) {
            ZHJLog([LogManager getClassForCoderName:self],@"读取缓存 成功");
            [[ZHJNetworkManager defaultManager] hideAlert];
            success(YES,object);
            [weakSelf printParamSeting:parameterDic task:nil response:object];
        } else {
            ZHJLog([LogManager getClassForCoderName:self],@"读取缓存 失败");
            weakSelf.isCache = YES;
            Config.isCache = NO;
            [[ZHJNetworkManager defaultManager] sendRequestMethod:Config progress:progress success:success failure:failure];
        }
    } else {
        // https SSL验证
        if (Config.certificatesName.length>0) {
            [_sessionManager setSecurityPolicy:[self customSecurityPolicy:Config.certificatesName]];
        }
        
        NSURLSessionDataTask * httpDataTask = nil;
        switch (Config.methodType) {
            case RequestMethod_Get:
            {
                httpDataTask = [_sessionManager GET:requestPath parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                    if (progress) {
                        progress(downloadProgress,Config.tag);
                    }
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                    //设置缓存保存缓存数据
                    weakSelf.isCache?[[ZHJNetCacheManger sharedManager] cacheDataWithUrl:task.originalRequest.URL.absoluteString withData:responseObject]:nil;
                    //                    weakSelf.isCache?[ZHJNetCacheManger setHttpCache:responseObject URL:requestPath params:parameters]:nil;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
                
            case RequestMethod_Post:
            {
                httpDataTask = [_sessionManager POST:requestPath parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                    if (progress) {
                        progress(downloadProgress,Config.tag);
                    }
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                    //设置缓存保存缓存数据
                    weakSelf.isCache?[[ZHJNetCacheManger sharedManager] cacheDataWithUrl:task.originalRequest.URL.absoluteString withData:responseObject]:nil;
                    //                    weakSelf.isCache?[ZHJNetCacheManger setHttpCache:responseObject URL:requestPath params:parameters]:nil;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
                
            case RequestMethod_Put:
            {
                httpDataTask = [_sessionManager PUT:requestPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                    //设置缓存保存缓存数据
                    weakSelf.isCache?[[ZHJNetCacheManger sharedManager] cacheDataWithUrl:task.originalRequest.URL.absoluteString withData:responseObject]:nil;
                    //                    weakSelf.isCache?[ZHJNetCacheManger setHttpCache:responseObject URL:requestPath params:parameters]:nil;
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
                
            case RequestMethod_Patch:
            {
                httpDataTask = [_sessionManager PATCH:requestPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    [weakSelf.sessionTaskArr removeObject:task];
                    failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
                }];
            }
                break;
                
            case RequestMethod_Delete:
            {
                httpDataTask = [_sessionManager DELETE:requestPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
                    // 移除task 任务
                    [weakSelf.sessionTaskArr removeObject:task];
                    if (success) {
                        success(YES,responseObject);
                        [weakSelf printParamSeting:parameters task:task response:responseObject];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [[ZHJNetworkManager defaultManager] hideAlert];
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

#pragma mark 下载文件
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                             progress:(HttpProgress)progress
                              success:(void(^)(NSString *))success
                              failure:(nullable void(^) (NSString  *_Nullable error))failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"downloadDir = %@",downloadDir);
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(failure && error) {failure(error.description) ; return ;};
        success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;
    }];
    //开始下载
    [downloadTask resume];
    downloadTask ? [[ZHJNetworkManager defaultManager].sessionTaskArr addObject:downloadTask] : nil ;
    return downloadTask;
}

#pragma mark POST 表单上传
-(nullable NSURLSessionDataTask *)sendPOSTRequestWithserverUrl:(ZHJRequestConfig*)Config
                                      constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                                       progress:(nullable void (^)(NSProgress * _Nullable progress))progress
                                                        success:(nullable void(^) (BOOL isSuccess, id _Nullable responseObject))success
                                                        failure:(nullable void(^) (NSString  *_Nullable error))failure {
    WS(weakSelf);
    [ZHJNetworkManager openNetworkActivityIndicator:YES];
    //     设置超时时间
    if (Config.timeoutInterval != 20 ) {
        [ZHJNetworkManager setRequestTimeoutInterval:Config.timeoutInterval];
    }
    // Loading
    if (Config.hudIsShow) {
        [MBManager showLoading];
    }
    // 参数
    __block NSDictionary *parameters = [Config.parameters mutableCopy];
    
    NSURLSessionDataTask * httpDataTask = nil;
    httpDataTask = [_sessionManager POST:Config.path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (block) {block(formData);}
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {progress(uploadProgress);}
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[ZHJNetworkManager defaultManager] hideAlert];
        // 移除task 任务
        [weakSelf.sessionTaskArr removeObject:task];
        if (success) {
            success(YES,responseObject);
            [weakSelf printParamSeting:parameters task:task response:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[ZHJNetworkManager defaultManager] hideAlert];
        [weakSelf.sessionTaskArr removeObject:task];
        failure?failure([self failHandleWithErrorResponse:error ParamSeting:parameters task:task]):nil;
    }];
    // 添加sessionTask到数组
    httpDataTask ? [[ZHJNetworkManager defaultManager].sessionTaskArr addObject:httpDataTask] : nil ;
    return httpDataTask;
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

#pragma mark 隐藏小菊花、loding
-(void)hideAlert {
    [MBManager hideAlert];
    [ZHJNetworkManager openNetworkActivityIndicator:NO];
}

#pragma mark 请求参数打印
-(void)printParamSeting:(NSDictionary*)dic task:( NSURLSessionDataTask * _Nullable )task response:(id)responseObject {
    if (dic||task) {
        if (task) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            if (response) {
                dic = @{@"URL":response.URL.absoluteString,@"header":response.allHeaderFields};
            }
            if (dic) {
                 dic = @{@"URL":response.URL.absoluteString,@"header":response.allHeaderFields,@"param":dic};
            }
        }
        ZHJLog([LogManager getClassForCoderName:self],@"请求头：\n",[LogManager convertToJsonData:dic]);
    }
   
    if (responseObject) {
        ZHJLog([LogManager getClassForCoderName:self],@"请求完成response：\n",[LogManager convertToJsonData:responseObject]);
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
    ZHJLog([LogManager getClassForCoderName:self],@"afNetworking_错误信息:/n",[[NSString alloc]initWithData:afNetworking_errorMsg encoding:NSUTF8StringEncoding]);
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
    ZHJLog([LogManager getClassForCoderName:self],@"错误信息",message);
    NSLog(@"错误信息：\n %@",message);
    return message;
}

@end

#pragma mark - NSDictionary,NSArray的分类
/*
 *新建NSDictionary与NSArray的分类, 控制台打印json数据中的中文 并不是真正的标准json
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


