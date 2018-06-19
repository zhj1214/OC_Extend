//
//  WeatherInfoTestModel.m
//  OC_Extend_Example
//
//  Created by 红军张 on 2018/6/14.
//  Copyright © 2018年 zhj1214. All rights reserved.
//

#import "WeatherInfoTestModel.h"

@implementation WeatherInfoTestModel

//返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"windDirection" : @"WD",
             @"cityName" : @"city",
             @"Humidity" : @[@"SD",@"ID",@"book_id"]};
}

// 如果实现了该方法，则处理过程中会忽略该列表内的所有属性
+ (NSArray *)modelPropertyBlacklist {
    return @[@"rain0", @"rain1"];
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
//+ (NSArray *)modelPropertyWhitelist {
//    return @[@"name"];
//}


@end
