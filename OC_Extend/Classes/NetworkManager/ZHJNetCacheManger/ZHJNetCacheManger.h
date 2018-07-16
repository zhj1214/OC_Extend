//
//  ZHJNetCacheManger.h
//  AFNetworking
//
//  Created by 红军张 on 2018/6/15.
//

#import <Foundation/Foundation.h>

@interface ZHJNetCacheManger : NSCache

/**
 创建 NSCache单利

 @return ZHJNetCacheManger
 */
+ (ZHJNetCacheManger *)sharedManager;

/**
 保存

 @param url key
 @param jsonData value
 */
- (void)cacheDataWithUrl:(NSString *)url withData:(id)jsonData;

/**
 读取

 @param url key
 @return value
 */
- (id)getCacheDataWithUrl:(NSString *)url;

/**
 删除指定key缓存

 @param url key
 */
-(void)removeCacheDataWithKey:(NSString *)url;

/**
 清楚所有缓存
 */
-(void)cacheRemoveAllObjects;
@end
