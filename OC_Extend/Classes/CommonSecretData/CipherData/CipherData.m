//
//  CipherData.m
//  encryptionTest
//
//  Created by 红军张 on 2018/4/27.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import "CipherData.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonCrypto.h>


size_t const kKeySize = kCCKeySizeAES128;

#pragma mark: ----- AES加密/解密 核心方法
NSData * cipherOperation(NSData *contentData, NSData *keyData, NSData *ivData, CCOperation operation) {
    NSUInteger dataLength = contentData.length;
    
    void const *contentBytes = contentData.bytes;
    void const *keyBytes = keyData.bytes;
    void const *initVectorBytes = ivData.bytes;
    
    size_t operationSize = dataLength + kCCBlockSizeAES128;
    void *operationBytes = malloc(operationSize);
    if (operationBytes == NULL) {
        return nil;
    }
    size_t actualOutSize = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyBytes,
                                          kKeySize,
                                          initVectorBytes,
                                          contentBytes,
                                          dataLength,
                                          operationBytes,
                                          operationSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:operationBytes length:actualOutSize];
    }
    free(operationBytes);
    operationBytes = NULL;
    return nil;
}

#pragma mark: ----- AES加密/解密 返回 Nsstring类型
NSString * aesEncryptString(NSString *content, NSString *key,NSString *iv) {
    NSCParameterAssert(content);
    NSCParameterAssert(key);
    NSCParameterAssert(iv);
    
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *ivData = [[NSData alloc] initWithBase64EncodedString:iv options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *encrptedData = aesEncryptData(contentData, keyData, ivData);
    return [encrptedData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

NSString * aesDecryptString(NSString *content, NSString *key, NSString *iv) {
    NSCParameterAssert(content);
    NSCParameterAssert(key);
    NSCParameterAssert(iv);
    
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *ivData = [[NSData alloc] initWithBase64EncodedString:iv options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decryptedData = aesDecryptData(contentData, keyData, ivData);
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

#pragma mark: ----- AES加密/解密 返回 Nsdata类型
NSData * aesEncryptData(NSData *contentData, NSData *keyData,NSData *ivData) {
    NSCParameterAssert(contentData);
    NSCParameterAssert(keyData);
    NSCParameterAssert(ivData);
    
    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];
    NSCAssert(keyData.length == kKeySize, hint);
    return cipherOperation(contentData, keyData, ivData, kCCEncrypt);
}

NSData * aesDecryptData(NSData *contentData, NSData *keyData,NSData *ivData) {
    NSCParameterAssert(contentData);
    NSCParameterAssert(keyData);
    NSCParameterAssert(ivData);
    
    NSString *hint = [NSString stringWithFormat:@"The key size of AES-%lu should be %lu bytes!", kKeySize * 8, kKeySize];
    NSCAssert(keyData.length == kKeySize, hint);
    return cipherOperation(contentData, keyData, ivData, kCCDecrypt);
}

#pragma mark: ----- MD5
NSString * MD5EncryptString(NSString *content) {
    
    if (content == nil) {return nil;}
    
    const char *cStr = [content UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


#pragma mark: ----- base64 编码/解码 返回 Nsstring 类型
NSString * base64EncryptString(NSString *content) {
    //1.先把字符串转换为二进制数据 NSUTF8StringEncoding
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    //2.对二进制数据进行base64编码，返回编码后的字符串
    //这是苹果已经给我们提供的方法
    return [data base64EncodedStringWithOptions:0];
}

NSString * base64DecryptString(NSString *content) {
    //1 转换为二进制数据（注意：该字符串是base64编码后的字符）
    NSData *data = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //2 把二进制数据转化为字符串
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark: ----- base64 编码/解码 返回 Data 类型
NSString * base64EncryptData(NSData *content) {
    return [content base64EncodedStringWithOptions:0];
}

NSString * base64DecryptData(NSData *content) {
    return [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
}

#pragma mark: ----- base64 编码
static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

NSString * base64StringFromData(NSData *data,NSUInteger length) {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    lentext = [data length];
    if (lentext < 1) {
        return @"";
    }
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0) {
            break;
        }
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext) {
                input[i] = raw[ix];
            }
            else {
                input[i] = 0;
            }
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++) {
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        }
        
        for (i = ctcopy; i < 4; i++) {
            [result appendString: @"="];
        }
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length)) {
            charsonline = 0;
        }
    }
    return result;
}


