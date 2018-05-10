//
//  MBProgressHUD+ZHJ.h
//  testAPP
//
//  Created by 红军张 on 2018/3/26.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexValue)

+(UIColor *)colorWithHexStringAlpha:(NSString *)color alpha:(CGFloat)alpha;

+ (UIColor*)colorWithHexValue:(NSString*)hex;
+ (UIColor *)colorWithHex:(uint)hex alpha:(CGFloat)alpha;

@end
