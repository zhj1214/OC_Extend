//
//  ZHJAlertViewController.m
//  encryptionTest
//
//  Created by 红军张 on 2018/5/9.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import "ZJAlertViewController.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

static const char AlertBlockKey;

@implementation ZHJAlertViewController

//单例
+ (ZHJAlertViewController *) sharedInstance{
    static ZHJAlertViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZHJAlertViewController alloc] init];
    });
    return instance;
}

#pragma mark -设置弹出的alertView
+(void)alertShowTitle:(nullable NSString *)title
              message:(nullable NSString *)message
    cancelButtonTitle:(nullable NSString *)cancelButtonTitle
    otherButtonTitles:(nullable NSString *)otherButtonTitles
                block:(nullable continueBlock)alertBlock
{
    [[ZHJAlertViewController sharedInstance] ZJ_AlertShowTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles block:^(NSInteger buttonIndex) {
        if (alertBlock) {
            alertBlock(buttonIndex);
        }
    }];
}

-(void)ZJ_AlertShowTitle:(nullable NSString*)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString*)cancelButtontitle otherButtonTitles:(nullable NSString*)otherButtonTitles block:(nullable continueBlock)continueAlertBlock{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        if (cancelButtontitle.length){
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:cancelButtontitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                continueAlertBlock(0);
            }];
            [alert addAction:defaultAction];
        }
        
        if (otherButtonTitles.length) {
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                continueAlertBlock(1);
            }];
            [alert addAction:defaultAction];
        }
        
        UIViewController *currentViewController = [UIViewController currentViewController];
        [currentViewController presentViewController:alert animated:YES completion:nil];
        
    }else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtontitle otherButtonTitles:otherButtonTitles , nil];
        //添加运行时的设置传递，处理代理方法的设置
        objc_removeAssociatedObjects(alertView);
        alertView.delegate = self;
        objc_setAssociatedObject(alertView, &AlertBlockKey, continueAlertBlock, OBJC_ASSOCIATION_COPY);
        [alertView show];
    }
}


+ (void)alertShowWithMsg:(nullable NSString *)message
           continueBlock:(nullable continueNoParamBlock)continueBlock
             cancelBlock:(nullable continueNoParamBlock)cancelBlock{
    
    [self alertShowTitle:@"提示信息" message:message cancelButtonTitle:@"取消" otherButtonTitles:@"确定" block:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            if (cancelBlock) {
                cancelBlock();
            }
        }else{
            if (continueBlock) {
                continueBlock();
            }
        }
    }];
}
+(void)alertShowWithMsg:(nullable NSString *)message
          continueTitle:(nullable NSString *)title
          continueBlock:(nullable continueNoParamBlock)continueBlock
{
    [self alertShowTitle:@"提示信息" message:message cancelButtonTitle:nil otherButtonTitles:title block:^(NSInteger buttonIndex) {
        if (continueBlock) {
            continueBlock();
        }
    }];
}



//alertView的代理方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    continueBlock alertBlock = (continueBlock)objc_getAssociatedObject(alertView, &AlertBlockKey);
    if (alertBlock) {
        alertBlock(buttonIndex);
    }
}

@end
