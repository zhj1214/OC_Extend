//
//  TestNSURLSessionTask.h
//  OC_Extend_Example
//
//  Created by 红军张 on 2018/6/29.
//  Copyright © 2018年 zhj1214. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestNSURLSessionTask : UIViewController<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDataDelegate>

@property (weak, nonatomic) IBOutlet UIImageView * imageview;
@property (strong,nonatomic)NSURLSession * session;
@property (strong,nonatomic)NSURLSessionDataTask * dataTask;
@property (weak, nonatomic) IBOutlet UIProgressView *progressview;
@property (nonatomic)NSUInteger expectlength;
@property (strong,nonatomic) NSMutableData * buffer;

@end
