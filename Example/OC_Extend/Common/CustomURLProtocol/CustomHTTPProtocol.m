//
//  CustomHTTPProtocol.m
//  ZBtest
//
//  Created by 红军张 on 2018/6/21.
//  Copyright © 2018年 ZBtest. All rights reserved.
//

#import "CustomHTTPProtocol.h"

@interface CustomHTTPProtocol ()

@property (nonatomic, strong) NSURLSession *managerSession;

@end

@implementation CustomHTTPProtocol
#pragma mark - Private
- (NSURLSession *)managerSession {
    if (!_managerSession) {
        _managerSession = [NSURLSession sessionWithConfiguration:[CustomHTTPProtocol defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _managerSession;
}

+ (NSURLSessionConfiguration *) defaultSessionConfiguration {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableArray *array = [[config protocolClasses] mutableCopy];
    [array insertObject:[self class] atIndex:0];
    config.protocolClasses = array;
    return config;
}
#pragma mark --  注册
+ (void)registerInterceptor {
    [NSURLProtocol registerClass:[CustomHTTPProtocol class]];
}

#pragma mark -- 移除 注册
+ (void)unregisterInterceptor {
    [NSURLProtocol unregisterClass:[CustomHTTPProtocol class]];
}

#pragma mark -- task 这里可以拿到 请求参数
+ (BOOL)canInitWithTask:(NSURLSessionTask *)task {
    if (task.originalRequest.HTTPBody) {
        NSString *body = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
        NSLog(@"originalRequest %@ 我拿到了参数 %@",task.originalRequest.HTTPMethod,body);
    }
    return [self canInitWithRequest:task.currentRequest];
}

#pragma mark -- 决定哪些请求需要当前协议对象处理
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSLog(@"11111_____11111 请求链接 %@ __%@ __%@",request.URL.absoluteString,request.URL.scheme,request);
    BOOL shouldAccept;
    NSURL *url;
    NSString *scheme;
    
    shouldAccept = (request != nil);
    if (shouldAccept) {
        url = [request URL];
        shouldAccept = (url != nil);
        scheme = request.URL.scheme;
        
        if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
            [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
            //看看是否处理过,防止无限循环
            if ([self propertyForKey:hasInitKey inRequest:request]) {
                NSLog(@"标记***************************有作用了");
                return NO;
            }
            
            if ([request.URL.absoluteString containsString:@"auth.zjdex.com"]) {
                NSLog(@"拦截");
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark -- 对当前的请求对象需要进行哪些处理
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
//    这里对请求不做任何修改，直接返回，当然你也可以给这个请求加个 header，只要最后返回一个 NSURLRequest 对象就可以 重定向 定制化服务
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSString *originalUrl = mutableRequest.URL.absoluteString;
    NSURL *url = [NSURL URLWithString:originalUrl];
    
    NSString *ip = nil; //处理ip映射
    if (ip) {
        NSRange hostFirstRange = [originalUrl rangeOfString:url.host];
        if (NSNotFound != hostFirstRange.location) {
            NSString *newUrl = [originalUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
            mutableRequest.URL = [NSURL URLWithString:newUrl];
            [mutableRequest setValue:url.host forHTTPHeaderField:@"host"];
            // 添加originalUrl保存原始URL
            [mutableRequest addValue:originalUrl forHTTPHeaderField:@"originalUrl"];
        }
    }
    return mutableRequest;
}

#pragma mark -- 判断两个 request 是否相同，如果相同的话可以使用缓存数据，通常只需要调用父类的实现。
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

#pragma mark -- 初始化一个 NSURLProtocol 对象
- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

#pragma mark --  发送请求
- (void)startLoading {
    NSMutableURLRequest *request = [self.request mutableCopy];
    [[self class] setProperty:@(YES)  forKey: hasInitKey inRequest: request];
    NSURLSessionDataTask *task = [self.managerSession dataTaskWithRequest:request];
    if (task.state == NSURLSessionTaskStateSuspended) {
        [task resume];
    }
}

#pragma mark -- NSURLSessionDelegate
//web服务器接收到客户端请求时，有时候需要先验证客户端是否为正常用户，再决定是够返回真实数据。
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    NSLog(@"666666_____66666 NSURLSessionTaskDelegate:::询问>>服务器需要客户端配合验证--任务级别");
    //AFNetworking中的处理方式
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    
    __block NSURLCredential *credential = nil;
    
    // 判断是否是信任服务器证书
    if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        // 告诉服务器，客户端信任证书
        // 创建凭据对象
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    
    completionHandler(disposition,credential);
    NSLog(@"protectionSpace = %@",challenge.protectionSpace);
}

//当session中所有已经入队的消息被发送出去后，会调用该代理方法。
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session API_AVAILABLE(ios(7.0), watchos(2.0), tvos(9.0)) API_UNAVAILABLE(macos) {
    NSLog(@"NSURLSessionDelegate:::通知>>所有后台下载任务全部完成");
}

// 当前这个session已经失效时，该代理方法被调用。
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    NSLog(@"*****end***** NSURLSessionDelegate:::通知>>session被关闭");
}

#pragma mark -- NSURLSessionDataDelegate
//告诉代理，该data task获取到了服务器端传回的最初始回复（response）。注意其中的completionHandler这个block，通过传入一个类型为NSURLSessionResponseDisposition的变量来决定该传输任务接下来该做什么：
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

#pragma mark -- NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

#pragma mark -- 停止相应请求，清空请求Connection 或Task。
-(void)stopLoading {
    //    如果你使用finishTasksAndInvalidate函数使该session失效，那么session首先会先完成最后一个task，然后再调用URLSession:didBecomeInvalidWithError:代理方法，如果你调用invalidateAndCancel方法来使session失效，那么该session会立即调用上面的代理方法。
    
    //    [self.managerSession invalidateAndCancel];
    
    [self.managerSession finishTasksAndInvalidate];
    
}
@end
