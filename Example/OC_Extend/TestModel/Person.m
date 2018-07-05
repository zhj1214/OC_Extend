//
//  Person.m
//  MethodSwizzlingTest
//
//  Created by 红军张 on 2018/6/5.
//  Copyright © 2018年 红军张. All rights reserved.
//

#import "Person.h"
#import "Person+Car.h"

@interface Person()

@property(nonatomic,assign) NSInteger age;

@end

@implementation Person {
    NSString *per;
}

-(void)seting {
    self.person = [NSString stringWithFormat:@"我是%@",[[UIDevice currentDevice] name]];
}

-(NSString*)personInfo:(NSString*)name {
    NSLog(@"此方法只有一句 输出 %@逗逼你好",name);
    return @"好了吧";
}

+(void)personPublic {
    NSLog(@"脑阔儿疼");
}

+(void)dynamicAddMethod {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    Person *c = [[Person alloc] init];
    [c performSelector:@selector(zhj) withObject:@"你好啊，你真帅"];
#pragma clang diagnostic pop
    
}

@end
