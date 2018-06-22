//
//  CustomHTTPProtocol.h
//  ZBtest
//
//  Created by 红军张 on 2018/6/21.
//  Copyright © 2018年 ZBtest. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const hasInitKey = @"LLMarkerProtocolKey";

@interface CustomHTTPProtocol : NSURLProtocol<NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

+ (void)registerInterceptor;

+ (NSURLSessionConfiguration *) defaultSessionConfiguration;
@end
