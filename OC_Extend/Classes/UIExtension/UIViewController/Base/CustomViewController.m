//
//  CustomViewController.m
//  MixdataDemo_Example
//
//  Created by 红军张 on 2018/5/25.
//  Copyright © 2018年 zhj1214. All rights reserved.
//

#import "CustomViewController.h"

@interface CustomViewController ()<UIGestureRecognizerDelegate>

@end

@implementation CustomViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11.0, *)) {
        self.view.insetsLayoutMarginsFromSafeArea = NO;
        UIEdgeInsets insets = self.view.safeAreaInsets;
        insets.top = -20;
        self.additionalSafeAreaInsets = insets;
    }
    
    NSLog(@"进入 %@",self.classForCoder);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

-(void)setup {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"离开 %@",self.classForCoder);
}

@end
