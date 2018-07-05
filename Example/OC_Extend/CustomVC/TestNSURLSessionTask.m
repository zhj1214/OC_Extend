//
//  TestNSURLSessionTask.m
//  OC_Extend_Example
//
//  Created by 红军张 on 2018/6/29.
//  Copyright © 2018年 zhj1214. All rights reserved.
//

#import "TestNSURLSessionTask.h"

@interface TestNSURLSessionTask ()

@end

static NSString * imageURL = @"http://down.699pic.com/photo/00037/9614.jpg?_upt=8569e26b1530262943&_upd=379614.jpg";

@implementation TestNSURLSessionTask

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dataTask resume];//Task要resume彩绘进行实际的数据传输
    [self.session finishTasksAndInvalidate];//完成task就invalidate
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - lazy property
-(NSMutableData *)buffer{
    if (!_buffer) {
        _buffer = [[NSMutableData alloc] init];
    }
    return _buffer;
}
-(NSURLSession*)session{
    if (!_session) {
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}
-(NSURLSessionDataTask *)dataTask{
    if (!_dataTask) {
        _dataTask = [self.session dataTaskWithURL:[NSURL URLWithString:imageURL]];
    }
    return _dataTask;
}

#pragma mark - target-action
//注意判断当前Task的状态
- (IBAction)start:(UIButton *)sender {
    if (self.dataTask.state == NSURLSessionTaskStateSuspended) {
        [self.dataTask resume];
    }
}
    
- (IBAction)pause:(UIButton *)sender {
    if (self.dataTask.state == NSURLSessionTaskStateRunning) {
        [self.dataTask suspend];
    }
}

- (IBAction)cancel:(id)sender {
    switch (self.dataTask.state) {
        case NSURLSessionTaskStateRunning:
        case NSURLSessionTaskStateSuspended:
            [self.dataTask cancel];
            break;
        default:
            break;
    }
}

#pragma mark -  URLSession delegate method
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSUInteger length = [response expectedContentLength];
    if (length != -1) {
        self.expectlength = [response expectedContentLength];//存储一共要传输的数据长度
        completionHandler(NSURLSessionResponseAllow);//继续数据传输
    }else{
        completionHandler(NSURLSessionResponseCancel);//如果Response里不包括数据长度的信息，就取消数据传输
        [ZHJAlertViewController alertShowWithMsg:@"Do not contain property of expectedlength" continueTitle:@"OK" continueBlock:^{
            NSLog(@"提示框");
        }];
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.buffer appendData:data];//数据放到缓冲区里
    self.progressview.progress = [self.buffer length]/((float) self.expectlength);//更改progressview的progress
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
            UIImage * image = [UIImage imageWithData:self.buffer];
            self.imageview.image = image;
            self.progressview.hidden = YES;
            self.session = nil;
            self.dataTask = nil;
        });
    }else{
        NSDictionary * userinfo = [error userInfo];
        NSString * failurl = [userinfo objectForKey:NSURLErrorFailingURLStringErrorKey];
        NSString * localDescription = [userinfo objectForKey:NSLocalizedDescriptionKey];
        if ([failurl isEqualToString:imageURL] && [localDescription isEqualToString:@"cancelled"]) {//如果是task被取消了，就弹出提示框
            [ZHJAlertViewController alertShowWithMsg:@"The task is canceled" continueTitle:@"OK" continueBlock:^{
                NSLog(@"提示框");
            }];
        }else{
            [ZHJAlertViewController alertShowWithMsg:@"Unknown type error" continueTitle:@"OK" continueBlock:^{
                NSLog(@"提示框");
            }];
        }
        self.progressview.hidden = YES;
        self.session = nil;
        self.dataTask = nil;
    }
}
@end
