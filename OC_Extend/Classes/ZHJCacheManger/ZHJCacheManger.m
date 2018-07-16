//
//  ZHJCacheManger.m
//  AFNetworking
//
//  Created by 红军张 on 2018/6/15.
//

#import "ZHJCacheManger.h"
#import <YYCache/YYCache.h>

@implementation ZHJCacheManger

static NSString *const ZHJNetCache = @"ZJNetCacheManager";
static YYCache *_Cache;

//初始化YYCache
+(void)initialize{
    _Cache = [YYCache cacheWithName:ZHJNetCache];
}


+(void)setHttpCache:(id)httpData URL:(NSString *)URL params:(NSDictionary *)params{
    NSString *cacheKey = [self cacheKeyWithURL:URL params:params];
    //异步缓存
    [_Cache setObject:httpData forKey:cacheKey withBlock:nil];
}

+(id)getHttpCacheWithURL:(NSString *)URL params:(NSDictionary *)params{
    NSString *cahceKey = [self cacheKeyWithURL:URL params:params];
    return [_Cache objectForKey:cahceKey];
}


+(void)getHttpCacheWithURL:(NSString *)URL params:(NSDictionary *)params withBlock:(void (^)(id<NSCoding>))block{
    NSString *cahceKey = [self cacheKeyWithURL:URL params:params];
    [_Cache objectForKey:cahceKey withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(object);
        });
    }];
}

+(NSInteger)getAllHttpCacheSize{
    return [_Cache.diskCache totalCost];
}

+(void)removeAllHttpCache{
    [_Cache.diskCache removeAllObjects];
}


+(NSString*)cacheKeyWithURL:(NSString*)URL params:(NSDictionary*)params{
    if (!params) return URL;
    //参数转字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *paramsString = [[NSString alloc]initWithData:stringData encoding:NSUTF8StringEncoding];

    return [NSString stringWithFormat:@"%@%@",URL,paramsString];
}
@end
