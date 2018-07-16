//
//  ZHJRequestConfig.m
//  NetWorking
//
//  Created by 红军张 on 2018/7/5.
//  Copyright © 2018年 红军张. All rights reserved.
//

#import "ZHJRequestConfig.h"
#import "ZHJNetWorkingStatus.h"
#import "ZHJNetworkManager.h"
#import "LogManager.h"

@implementation ZHJRequestConfig
#pragma mark -- private

-(NSString*)baseUrl {
    if (_baseUrl.length<1) {
        _baseUrl = @"http://www.weather.com.cn";
    }
    return _baseUrl;
}

#pragma mark -- Request 初始化方法
+ (instancetype)sharedRequestWithMethodType:(RequestMethod)methodType withPath:(NSString *)path withParam:(NSDictionary *)paramDic {
    return [[self alloc]initWithMethodType:methodType WithPath:path withParam:paramDic withData:nil];
}

+ (instancetype)sharedRequestWithData:(NSData *)data withPath:(NSString *)path withParam:(NSDictionary *)paramDic withConfig:(ZHJRequestConfig *)config {
    return [[self alloc]initWithMethodType:RequestMethod_Post WithPath:path withParam:paramDic withData:data];
}

- (instancetype)initWithMethodType:(RequestMethod)methodType WithPath:(NSString *)path withParam:(NSDictionary *)paramDic withData:(NSData *)data {
    self = [super init];
    if (!self) {
        return nil;
    }
//    开启网络监测
    [ZHJNetWorkingStatus startMonitoring:^(BOOL isNet) {
        if (!isNet) {
            ZHJLog([LogManager getClassForCoderName:self],@"无网络，取消所有请求");
            [ZHJNetworkManager cancelAllRequest];
        }
    }];
    
    ZHJLog([LogManager getClassForCoderName:self],@"开始 新请求");
    _path = path;
    _data = data;
    _methodType = methodType;
    _parameters = paramDic;
    ZHJLog([LogManager getClassForCoderName:self],@"请求参数",paramDic);
    
//    完整的地址链接
    _fullPath = [self.baseUrl stringByAppendingString:path];
    
//    增加自定义参数
    _url = [self genUrlWithPath:_fullPath];
    
//    请求标记
    _tag = @"0";
    
//    默认超时时间
    _timeoutInterval = 20;
    
//    默认显示 loading
    _hudIsShow = YES;
    
    ZHJLog([LogManager getClassForCoderName:self],@"请求地址是：",_url.absoluteString);
    return self;
}

#pragma mark -- 自定义参数 拼接
- (NSURL *)genUrlWithPath:(NSString *)url {
    if (!url || [url isEqualToString:@""]) {
        return nil;
    }
    
    if (self.token.length>0) {
        url = [url stringByAppendingString:[self getConnector:url]];
        url=[url stringByAppendingFormat:@"%@=%@",@"token",self.token];
    }
    
    if (self.sig.length>0) {
        url = [url stringByAppendingString:[self getConnector:url]];
        url=[url stringByAppendingFormat:@"%@=%@",@"sig",self.sig];
    }
    
    if (self.timestamp.length>0) {
        url = [url stringByAppendingString:[self getConnector:url]];
        url=[url stringByAppendingFormat:@"%@=%@",@"timestamp",self.timestamp];
    }
    
    return [NSURL URLWithString:url];
}

- (NSString *)getConnector:(NSString *)url{
    NSString *connector = @"&";
    NSRange range = [url rangeOfString:@"?"];
    if (range.location ==NSNotFound){
        connector =  @"?";
    }
    return connector;
}
@end
