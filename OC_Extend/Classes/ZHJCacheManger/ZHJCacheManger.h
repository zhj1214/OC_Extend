//
//  ZHJCacheManger.h
//  AFNetworking
//
//  Created by 红军张 on 2018/6/15.
//

#import <Foundation/Foundation.h>

@interface ZHJCacheManger : NSObject

/**                 保存数据
 异步缓存数据，根据请求的URL和params做KEY存储数据 缓存多级页面的数据
 
 @param httpData 服务器返回的数据
 @param URL 请求的URL
 @param params 请求的参数
 */
+(void)setHttpCache:(id)httpData URL:(NSString*)URL params:(NSDictionary*)params;


/**                  获取缓存数据
 根据URL和params获取到对应的缓存数据
 
 @param URL 请求的URL
 @param params 请求参数
 @return 返回的缓存数据
 */
+(id)getHttpCacheWithURL:(NSString*)URL params:(NSDictionary*)params;


/**                 异步获取缓存数据
 根据URL和params获取缓存数据 异步返回缓存数据
 
 @param URL 请求URL
 @param params 请求参数
 @param block 异步回调block
 */
+(void)getHttpCacheWithURL:(NSString*)URL params:(NSDictionary*)params withBlock:(void(^)(id<NSCoding>object))block;

/**
 获取网络缓存的总大小  单位字节
 */
+(NSInteger)getAllHttpCacheSize;


/**
 删除所有的网络缓存
 */
+(void)removeAllHttpCache;

@end
