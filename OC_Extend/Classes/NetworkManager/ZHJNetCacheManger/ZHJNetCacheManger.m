//
//  ZHJNetCacheManger.m
//  AFNetworking
//
//  Created by 红军张 on 2018/6/15.
//

#import "ZHJNetCacheManger.h"
#import <UIKit/UIKit.h>

@implementation ZHJNetCacheManger

+ (ZHJNetCacheManger *)sharedManager{
    static ZHJNetCacheManger *sharedHTDataCacheInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedHTDataCacheInstance = [[self alloc] initWithCache];
        
    });
    return sharedHTDataCacheInstance;
}

- (instancetype)initWithCache {
    self = [super init];
    if (!self) {return nil;}
    //用于监听 UIMenuController的变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    return self;
}

- (void)cacheDataWithUrl:(NSString *)url withData:(id)jsonData {
    if (jsonData) {
        [[ZHJNetCacheManger sharedManager] setObject:jsonData forKey:url];
    }
}

- (id)getCacheDataWithUrl:(NSString *)url{
    return [[ZHJNetCacheManger sharedManager] objectForKey:url];
}

-(void)removeCacheDataWithKey:(NSString *)url{
    [[ZHJNetCacheManger sharedManager] removeObjectForKey:url];
}

-(void)cacheRemoveAllObjects {
    [[ZHJNetCacheManger sharedManager] removeAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end
