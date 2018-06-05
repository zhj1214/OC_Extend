//
//  NSString+Dictionary.h
//  IOS-Categories
//
//  Created by Jakey on 14-6-13.
//  Copyright (c) 2014年 jakey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DictionaryValue)
/**
 json字符串转 字典
 */
-(NSDictionary *) dictionaryValue;
@end
