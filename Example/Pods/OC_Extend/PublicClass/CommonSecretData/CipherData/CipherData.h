//
//  CipherData.h
//  encryptionTest
//
//  Created by 红军张 on 2018/4/27.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//  https://github.com/WelkinXie/AESCipher-iOS
//

#import <Foundation/Foundation.h>

/**
 *  AES String 加密
 *
 *  @param content    要加密的字符串
 *  @param key        加密 密码
 *  @param iv         偏移量
 *  @return 返回加密后的字符串
 */
NSString * aesEncryptString(NSString *content, NSString *key, NSString *iv);

/**
 *  AES String 解密
 *
 *  @param content    要加密的字符串
 *  @param key        加密 密码
 *  @param iv         偏移量
 *  @return 返回解密后的字符串
 */
NSString * aesDecryptString(NSString *content, NSString *key, NSString *iv);

/**
 *  AES Data 加密
 *
 *  @param data       要加密的数据
 *  @param key        加密 密码
 *  @param iv         偏移量
 *  @return 返回加密后的字符串
 */
NSData * aesEncryptData(NSData *data, NSData *key, NSData *iv);

/**
 *  AES Data 解密
 *
 *  @param data       要加密的数据
 *  @param key        加密 密码
 *  @param iv         偏移量
 *  @return 返回解密后的字符串
 */
NSData * aesDecryptData(NSData *data, NSData *key, NSData *iv);

/**
 *  MD5
 *
 *  @param content    要加密的字符串
 *  @return 返回加密后的字符串
 */
NSString * MD5EncryptString(NSString *content);

/**
 *  Base64 String 编码
 *
 *  @param content    要加密的字符串
 *  @return 返回加密后的字符串
 */
NSString * base64EncryptString(NSString *content);

/**
 *  Base64 String 解码
 *
 *  @param content       要加密的数据
 *  @return 返回解密后的字符串
 */
NSString * base64DecryptString(NSString *content);

/**
 *  Base64 Data 编码
 *
 *  @param content    要加密的字符串
 *  @return 返回加密后的字符串
 */
NSString * base64EncryptData(NSData *content);

/**
 *  Base64 Data 解码
 *
 *  @param content       要加密的数据
 *  @return 返回解密后的字符串
 */
NSString * base64DecryptData(NSData *content);

/**
 *  Base64 Data  length 解码
 *
 *  @param data       要加密的数据
 *  @param length     长度
 *  @return 返回加密后的字符串
 */
NSString * base64StringFromData(NSData *data,NSUInteger length);

NSData * zhjcleanUTF8(NSData *data);
