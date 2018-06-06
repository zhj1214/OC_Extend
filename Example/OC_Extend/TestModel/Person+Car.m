//
//  Person+Car.m
//  OC_Extend_Example
//
//  Created by 红军张 on 2018/6/6.
//  Copyright © 2018年 zhj1214. All rights reserved.
//

#import "Person+Car.h"

@implementation Person (Car)

- (void)startEngine:(NSString *)brand {
    NSLog(@"my %@ car starts the engine", brand);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(zhj)) {
        class_addMethod([self class], sel, class_getMethodImplementation(self, @selector(startEngine:)), "s@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

@end
