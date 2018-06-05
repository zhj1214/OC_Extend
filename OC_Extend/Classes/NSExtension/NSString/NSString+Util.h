//
//  NSString+Util.h
//  IOS-Categories
//
//  Created by Jakey on 15/5/22.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (Util)
/**
 根据字体宽度 获取高度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 根据字体高度 获取宽度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

/**
 根据字体宽度 获取size
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 根据字体高度度 获取size
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

/**
 字符串翻转
 */
+ (NSString *)reverseString:(NSString *)strSrc;
@end
