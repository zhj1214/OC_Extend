//
//  TestMethodSwizzling.h
//  OC_Extend_Example
//
//  Created by 红军张 on 2018/6/6.
//  Copyright © 2018年 zhj1214. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "Person.h"

@interface TestMethodSwizzling : NSObject

+(void)createObject;

+(void)getClassObjectName;

+(void)getSuperClassObjectName;

+(void)getInstanceVariableInfo;

+(void)getPropertyInfo;

+(void)getInstanceMethodInfo;
@end

