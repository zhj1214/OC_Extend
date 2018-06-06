//
//  Person.h
//  MethodSwizzlingTest
//
//  Created by 红军张 on 2018/6/5.
//  Copyright © 2018年 红军张. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Person : NSObject

@property (nonatomic,strong) NSString *person;

-(NSString*)personInfo:(NSString*)name;

+(void)personPublic;

+(void)dynamicAddMethod;
@end
