//
//  ZHJLayer.m
//  OC_Extend_Example
//
//  Created by 红军张 on 2018/7/12.
//  Copyright © 2018年 zhj1214. All rights reserved.
//

#import "ZHJLayer.h"

@implementation ZHJLayer {
    int number;
    NSString *valueStr;
}

@synthesize string = _string;

-(id)string {
    number = number + 1;
    if (number > 2) {
        return @"******";
    }
    if (!_string) {
        self.string = [NSString new];
    }
//    NSLog(@"进来了几次—————————————%@——啊",_string);
    return  _string;
}



@end
