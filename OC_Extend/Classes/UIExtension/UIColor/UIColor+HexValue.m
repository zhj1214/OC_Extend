//
//  MBProgressHUD+ZHJ.h
//  testAPP
//
//  Created by 红军张 on 2018/3/26.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import "UIColor+HexValue.h"

@implementation UIColor (HexValue)

+ (UIColor*)colorWithHexValue:(NSString*)hex {
    if (!hex) return nil;
    
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringFromIndex:1];
    }
    
    NSString *rStr = nil, *gStr = nil, *bStr = nil, *aStr = nil;
    
    if (hex.length == 3) {
        rStr = [hex substringWithRange:NSMakeRange(0, 1)];
        rStr = [NSString stringWithFormat:@"%@%@", rStr, rStr];
        gStr = [hex substringWithRange:NSMakeRange(1, 1)];
        gStr = [NSString stringWithFormat:@"%@%@", gStr, gStr];
        bStr = [hex substringWithRange:NSMakeRange(2, 1)];
        bStr = [NSString stringWithFormat:@"%@%@", bStr, bStr];
        aStr = @"FF";
    } else if (hex.length == 4) {
        rStr = [hex substringWithRange:NSMakeRange(0, 1)];
        rStr = [NSString stringWithFormat:@"%@%@", rStr, rStr];
        gStr = [hex substringWithRange:NSMakeRange(1, 1)];
        gStr = [NSString stringWithFormat:@"%@%@", gStr, gStr];
        bStr = [hex substringWithRange:NSMakeRange(2, 1)];
        bStr = [NSString stringWithFormat:@"%@%@", bStr, bStr];
        aStr = [hex substringWithRange:NSMakeRange(3, 1)];
        aStr = [NSString stringWithFormat:@"%@%@", aStr, aStr];
    } else if (hex.length == 6) {
        rStr = [hex substringWithRange:NSMakeRange(0, 2)];
        gStr = [hex substringWithRange:NSMakeRange(2, 2)];
        bStr = [hex substringWithRange:NSMakeRange(4, 2)];
        aStr = @"FF";
    } else if (hex.length == 8) {
        rStr = [hex substringWithRange:NSMakeRange(0, 2)];
        gStr = [hex substringWithRange:NSMakeRange(2, 2)];
        bStr = [hex substringWithRange:NSMakeRange(4, 2)];
        aStr = [hex substringWithRange:NSMakeRange(6, 2)];
    } else {
        // Unknown encoding
        return nil;
    }
    
    unsigned r, g, b, a;
    [[NSScanner scannerWithString:rStr] scanHexInt:&r];
    [[NSScanner scannerWithString:gStr] scanHexInt:&g];
    [[NSScanner scannerWithString:bStr] scanHexInt:&b];
    [[NSScanner scannerWithString:aStr] scanHexInt:&a];
    
    if (r == g && g == b) {
        // Optimal case for grayscale
        return [UIColor colorWithWhite:(((CGFloat)r)/255.0f) alpha:(((CGFloat)a)/255.0f)];
    } else {
        return [UIColor colorWithRed:(((CGFloat)r)/255.0f) green:(((CGFloat)g)/255.0f) blue:(((CGFloat)b)/255.0f) alpha:(((CGFloat)a)/255.0f)];
    }
}


+(UIColor *)colorWithHexStringAlpha:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}


+ (UIColor *) colorWithHex:(uint) hex alpha:(CGFloat)alpha
{
    int red, green, blue;
    
    blue = hex & 0x0000FF;
    green = ((hex & 0x00FF00) >> 8);
    red = ((hex & 0xFF0000) >> 16);
    
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
