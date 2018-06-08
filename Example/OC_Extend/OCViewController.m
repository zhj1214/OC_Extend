//
//  OCViewController.m
//  OC_Extend
//
//  Created by zhj1214 on 05/10/2018.
//  Copyright (c) 2018 zhj1214. All rights reserved.
//

#import "OCViewController.h"
#import "OC_ExtendHeader.h"
#import <GBDeviceInfo/GBDeviceInfo.h>
#import "ZHJLabel.h"

@interface OCViewController ()

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self getDeviceIPAddress];

    [self testMethodSwizzling];

    WS(weakSelf);
    [Tool delayStarFuntionGCD:3 block:^{
        [weakSelf delayMethod];
    }];
    
    [Tool drawText:self.label];
    NSLog(@" 看到的文字label 输出是%@",self.label.text);
}

#pragma mark: -- 获取设备信息
-(NSString *)getDeviceIPAddress {
    //方法一：此方法获取具体的ip地址
    IPToolManager *ipManager = [IPToolManager sharedManager];
    NSString *ip = [ipManager currentIpAddress];
    if (!ip) {
        ip = [ipManager currentIPAdressDetailInfo];
    }
    
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    NSLog(@"设备类型：%@ \n%@ \n手机型号：%@ \n系统版本：%@ \n设备的ip地址：%@ \n UDID %@",deviceName,userPhoneName,[GBDeviceInfo deviceInfo].modelString,phoneVersion,ip,ZHJUUID);
    
    NSLog(@"对 %@ 进行 AES 加密 %@",userPhoneName,[self getAESMiXString:userPhoneName]);
    
    NSLog(@"对 %@ 进行 SHA1哈希值 %@",userPhoneName,[self getSHA1String:userPhoneName]);
    return ip.length > 0 ? ip : @"error";
}

#pragma mark: -- testMethodSwizzling
-(void)testMethodSwizzling {
    [TestMethodSwizzling getClassObjectName];
    
    [TestMethodSwizzling createObject];
    
    [TestMethodSwizzling getSuperClassObjectName];
    
    [TestMethodSwizzling getInstanceVariableInfo];
    
    [TestMethodSwizzling getPropertyInfo];
    
    [TestMethodSwizzling getInstanceMethodInfo];
}

#pragma mark: -- 提示框
- (void)delayMethod {
    [ZHJAlertViewController alertShowTitle:@"welcome browse" message:@"逗逼你好" cancelButtonTitle:@"承认" otherButtonTitles:@"说得对" block:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            NSLog(@"有意思");
        } else {
            NSLog(@"你好");
        }
    }];
}

#pragma mark: ----- AES 加密
-(NSString *)getAESMiXString:(NSString*)content {
    return aesEncryptString(content, @"PV+Z04mDndhUopCm7RYcAg==", @"X6u1xFHanXpL/R90/Ndw6Q==");
}

#pragma mark: ----- 哈希
-(NSString *)getSHA1String:(NSString*)content {
    return [Tool signWithSHA1:content];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
