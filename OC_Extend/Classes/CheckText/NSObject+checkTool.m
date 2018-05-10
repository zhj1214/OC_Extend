//
//  NSObject+checkTool.m
//  qilinbao
//
//  Created by freestyle on 16/6/15.
//  Copyright © 2016年 freestyle. All rights reserved.
//

#import "NSObject+checkTool.h"

@implementation NSObject (checkTool)

#pragma mark - 邮箱校验
+(BOOL)checkForEmail:(NSString *)email{
    NSString *regEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self baseCheckForRegEx:regEx data:email];
}

#pragma mark - 验证手机号
+(BOOL)checkForMobilePhoneNo:(NSString *)mobilePhone {
    if(mobilePhone.length != 11){
        return NO;
    }
    /**
     * 手机号码
     * 移动：134[0-8],135、136、137、138、139、150、151、152、158、159、182、183、184、157、187、188、178、184、147
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189,181,177,173
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-9]|8[0-9]|7[0-9]|4[0-9]|2[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134、135、136、137、138、139、150、151、152、158、159、182、183、184、157、187、188、178、184、147
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[012789]|8[23478]|47|78\\d))\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186,176,145
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56]|7[6]|4[5])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,181,177,173
     22         */
    NSString * CT = @"^1(349|(33|53|8[019]|7[37])\\d)\\d{7}$";
    NSString * Other = @"^1(7[01]|2[58])\\d{8}$";
    /**
     *  虚拟运营商
     *  170、171、125、128
     */
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestother = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Other];
    if (([regextestmobile evaluateWithObject:mobilePhone] == YES)
        || ([regextestcm evaluateWithObject:mobilePhone] == YES)
        || ([regextestcu evaluateWithObject:mobilePhone] == YES)
        || ([regextestct evaluateWithObject:mobilePhone] == YES)
        || ([regextestother evaluateWithObject:mobilePhone] == YES)) {
        return YES;
    } else {
        return NO;
    }
}
#pragma mark - 验证电话号
+(BOOL)checkForPhoneNo:(NSString *)phone{
    NSString *regEx = @"^(\\d{3,4}-)\\d{7,8}$";
    return [self baseCheckForRegEx:regEx data:phone];
}

#pragma mark - 身份证号验证
+ (BOOL) checkForIdCard:(NSString *)idCard{
    
    NSString *regEx = @"\\d{14}[[0-9],0-9xX]";
    return [self baseCheckForRegEx:regEx data:idCard];
}
#pragma mark - 密码校验
+(BOOL)checkForPasswordWithShortest:(NSInteger)shortest longest:(NSInteger)longest password:(NSString *)pwd{
    NSString *regEx =[NSString stringWithFormat:@"^[a-zA-Z0-9]{%ld,%ld}+$", shortest, longest];
    return [self baseCheckForRegEx:regEx data:pwd];
}

//----------------------------------------------------------------------

#pragma mark - 由数字和26个英文字母组成的字符串
+ (BOOL) checkForNumberAndCase:(NSString *)data{
    NSString *regEx = @"^[A-Za-z0-9]+$";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 小写字母
+(BOOL)checkForLowerCase:(NSString *)data{
    NSString *regEx = @"^[a-z]+$";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 大写字母
+(BOOL)checkForUpperCase:(NSString *)data{
    NSString *regEx = @"^[A-Z]+$";
    return [self baseCheckForRegEx:regEx data:data];
}
#pragma mark - 26位英文字母
+(BOOL)checkForLowerAndUpperCase:(NSString *)data{
    NSString *regEx = @"^[A-Za-z]+$";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 特殊字符
+ (BOOL) checkForSpecialChar:(NSString *)data{
    NSString *regEx = @"[^%&',;=?$\x22]+";
    return [self baseCheckForRegEx:regEx data:data];
}

#pragma mark - 只能输入数字
+ (BOOL) checkForNumber:(NSString *)number{
    NSString *regEx = @"^[0-9]*$";
    return [self baseCheckForRegEx:regEx data:number];
}

#pragma mark - 校验只能输入n位的数字
+ (BOOL) checkForNumberWithLength:(NSString *)length number:(NSString *)number{
    NSString *regEx = [NSString stringWithFormat:@"^\\d{%@}$", length];
    return [self baseCheckForRegEx:regEx data:number];
}

#pragma mark -- 判断是否是英文名
+ (BOOL)isEnglishName:(NSString *)name{
    ChineseFormatType type = [self chineseFormat:[name stringByReplacingOccurrencesOfString:@" " withString:@""]];
    if ((type == NameAllEnglish)||(type == NameAllChinses)||(type == NameChinsesAndEnglish)) {
        return YES;
    }else{
        return NO;
    }
}

// 中文姓名格式   写的真麻烦以后有机会再优化
-(ChineseFormatType)chineseFormat:(NSString*)str {
    NSString *strName = str;
    NSString *allZM = @"^[A-Za-z]";
    NSString *chinese = @"[\u4e00-\u9fa5]";
    NSString *hasZF = @"^[A-Za-z\\u4e00-\u9fa5\\^/]+$";
    NSString *xiegang = @"/";
    NSString *number = @"[0-9]*[1-9][0-9]*";
    NSPredicate *isHasZF = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", hasZF];
    NSPredicate *isAllZM = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", allZM];
    NSPredicate *ischinese = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", chinese];
    NSPredicate *isNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", number];
    NSPredicate *isxiegang = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", xiegang];

    NSUInteger  englishNumber = 0;
    NSUInteger  chineseNumber = 0;
    BOOL firstCharChinese = YES;
    for(int i=0; i< [strName length]; i++) {
        NSString *c = [strName substringWithRange:NSMakeRange(i, 1)];
        // 包含有中文及全角标点符号(字符)
        if (![isHasZF evaluateWithObject:c]) {return NameHasZF;}
        // 包含数字
        if ([isNumber evaluateWithObject:c]) {return NameHasNumber;}
        // 中文中不能包含 /
        if ([isxiegang evaluateWithObject:c]) {
            if (chineseNumber != 0) {
                return NameAllChinsesError;
            }
        }
        if ([ischinese evaluateWithObject:c]) {
            chineseNumber ++;
            // 首字母不是中文 但后面含有中文
            if (englishNumber != 0) {return NameFirstCharNOChinses;}
        }
        if ([isAllZM evaluateWithObject:c] || [isxiegang evaluateWithObject:c]) {englishNumber ++;}
        // 首字母 不是中文
        if ( i == 0 && [isAllZM evaluateWithObject:c]) {firstCharChinese = NO;}
        // 再次发现中文字符的时候
        if ([ischinese evaluateWithObject:c] && !firstCharChinese) {return NameFirstCharNOChinses;}
    }
    if (chineseNumber == [strName length] && ([strName length] < 2 || [strName length] > 14)) {return NameNumberError;}
    if (englishNumber == [strName length] && ([strName length] < 2 || [strName length] > 28)) {return NameNumberError;}
    if (englishNumber != 0 && chineseNumber != 0) {
        if ((chineseNumber + englishNumber) > 28) {
            return NameNumberError;
        }
    }
    // 全中文
    if (chineseNumber == [strName length]) {return NameAllChinses;}
    // 全英文
    if (englishNumber == [strName length]) {
        if([strName rangeOfString:@"/"].location !=NSNotFound) {return NameAllEnglish;}
        return NameAllEnglishError;
    }
    return NameChinsesAndEnglish;
}

#pragma mark 汉子转拼音
+ (NSString *)chineseToEnglish:(NSString *)english{
    if (english.length<1) {return @"";}
    if([english rangeOfString:@"/"].location !=NSNotFound) {return english;}
    NSString *firstName = [self chineseTransformEnglish:[english substringToIndex:1]];
    NSString *lastName = [self chineseTransformEnglish:[english substringFromIndex:1]];
    return [NSString stringWithFormat:@"%@/%@",firstName,lastName];
}

-(NSString *)chineseTransformEnglish:(NSString *)chinese {
    if (chinese.length < 1) {return @"";}
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark - 私有方法
/**
 *  基本的验证方法
 *
 *  @param regEx 校验格式
 *  @param data  要校验的数据
 *
 *  @return YES:成功 NO:失败
 */
+(BOOL)baseCheckForRegEx:(NSString *)regEx data:(NSString *)data {
    
    NSPredicate *card = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    
    if (([card evaluateWithObject:data])) {
        return YES;
    }
    return NO;
}


@end
