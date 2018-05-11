//
//  OCViewController.m
//  OC_Extend
//
//  Created by zhj1214 on 05/10/2018.
//  Copyright (c) 2018 zhj1214. All rights reserved.
//

#import "OCViewController.h"
#import "OC_ExtendHeader.h"

@interface OCViewController ()

@end

@implementation OCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"AES 加密 %@",[self getAESMiXString:@"content"]);
    
    NSLog(@"哈希值 %@",[self getSHA1String:@"content"]);
    
    NSLog(@"uuuuuuuuuuuuuuuuuu ID%@",ZHJUUID);
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
