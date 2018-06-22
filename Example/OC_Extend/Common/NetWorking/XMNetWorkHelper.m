//
//  XMNetWorkHelper.m
//  ZBtest
//
//  Created by 红军张 on 2018/3/19.
//  Copyright © 2018年 ZBtest. All rights reserved.
//

#import "XMNetWorkHelper.h"
//#import "LogManager.h"
//#define SERVERURL @"https://auth.zjdex.com"
#define SERVERURL @"https://auth.zjdex.com/test"

NSString * const NetworkingOperationFailingURLResponseDataErrorKey = @"com.alamofire.serialization.response.error.data";

@implementation XMNetWorkHelper

#pragma mark: -- GET请求
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock {
    url = [SERVERURL stringByAppendingString:url];
    NSMutableString *mutableUrl = [[NSMutableString alloc] initWithString:url];
    if ([parameters allKeys]) {
        [mutableUrl appendString:@"?"];
        for (id key in parameters) {
            NSString *value = [[parameters objectForKey:key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [mutableUrl appendString:[NSString stringWithFormat:@"%@=%@&", key, value]];
        }
    }
    NSString *urlEnCode = [[mutableUrl substringToIndex:mutableUrl.length - 1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEnCode]];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlEnCode] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [urlSession dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //        [XMNetWorkHelper printParamSeting:parameters task:dataTask response:response];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                //            [XMNetWorkHelper failHandleWithErrorResponse:error task:dataTask];
                failureBlock(error);
            } else {
                NSError *error = nil;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if (!error) {
                    //                    NSLog(@"success：%@", dic);
                    successBlock(dic);
                } else {
//                    ZHJLog(@"数据解析失败",@"URL",url,error);
                    failureBlock(error);
                }
            }
        });
    }];
    [dataTask resume];
}

#pragma mark: -- POST请求 使用NSMutableURLRequest可以加入请求头
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock {
    
    NSURL *networkUrl = [NSURL URLWithString:[SERVERURL stringByAppendingString:url]];
    
    NSMutableURLRequest *mutableRequest=[NSMutableURLRequest requestWithURL:networkUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    //设置请求类型
    mutableRequest.HTTPMethod = @"POST";
    
    //将需要的信息放入请求头 随便定义了几个
    [mutableRequest setValue:@"1.0" forHTTPHeaderField:@"Version"];//版本
    //    NSLog(@"POST-Header:%@",mutableRequest.allHTTPHeaderFields);
    
    //把参数放到请求体内
    NSString *postStr = [XMNetWorkHelper convertToJsonData:parameters];
    
    mutableRequest.HTTPBody = [postStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [session dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //        [XMNetWorkHelper printParamSeting:parameters task:dataTask response:response];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) { //请求失败
                failureBlock(error);
                //            [XMNetWorkHelper failHandleWithErrorResponse:error task:dataTask];
            } else {  //请求成功
                NSError *error = nil;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if (!error) {
                    //                    NSLog(@"success：%@", dic);
                    successBlock(dic);
                } else {
//                    ZHJLog(@"数据解析失败",@"URL",url,error);
                    failureBlock(error);
                }
            }
        });
    }];
    [dataTask resume];  //开始请求
}

#pragma mark -- 表单上传
+ (void)postMultipartFormWithUrlString:(NSString *)kDetectUrl parameters:(id)parameters data:(NSData*)fileData success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock {
    
    // 以流的方式上传，大小理论上不受限制，但应注意时间
    // 1、创建URL资源地址
    NSURL *url = [NSURL URLWithString:kDetectUrl];
    // 2、创建Reuest请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 3、配置Request
    //设置Body值方法二，这种方法比较原始，不常用，不过可以用来上传参数和文件
    NSString *BOUNDARY = @"whoislcj";//表单分界线 可以自定义任意值
    [request setValue:[@"multipart/form-data; boundary=" stringByAppendingString:BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    // 文件上传使用post
    [request setHTTPMethod:@"POST"];
    // 设置请求超时
    [request setTimeoutInterval:30.0f];
    //用于存放二进制数据流
    NSMutableData *body = [NSMutableData data];
    
    //追加一个普通表单参数 name=yanzhenjie
    NSString *nameParam = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",BOUNDARY,@"api_id",[parameters objectForKey:@"api_id"],nil];
    [body appendData:[nameParam dataUsingEncoding:NSUTF8StringEncoding]];
    
    //追加一个普通表单参数 pwd=123
    NSString *pwdParam = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",BOUNDARY,@"api_secret",[parameters objectForKey:@"api_secret"],nil];
    [body appendData:[pwdParam dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *userNameParam = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",BOUNDARY,@"name",[parameters objectForKey:@"name"],nil];
    [body appendData:[userNameParam dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *numberParam = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",BOUNDARY,@"id_number",[parameters objectForKey:@"id_number"],nil];
    [body appendData:[numberParam dataUsingEncoding:NSUTF8StringEncoding]];
    
    //追加一个文件表单参数
    // Content-Disposition: form-data; name="<服务器端需要知道的名字>"; filename="<服务器端这个传上来的文件名>"
    // Content-Type: application/octet-stream --根据不同的文件类型选择不同的值
    NSString *file = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\";filename=\"%@\"\r\nContent-Type: Content-Type=image/png\r\n\r\n",BOUNDARY,@"liveness_data_file",@"zhjdem11.png",nil];
    [body appendData:[file dataUsingEncoding:NSUTF8StringEncoding]];
    //追加文件二进制数据
    [body appendData:fileData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //结束分割线
    NSString *endString = [NSString stringWithFormat:@"--%@--",BOUNDARY];
    [body appendData:[endString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 创建会话
    NSURLSession *session = [NSURLSession sharedSession];
    // 3.开始上传   request的body data将被忽略，而由fromData提供
    NSURLSessionUploadTask *uploadTask= [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
//                ZHJLog(@"表单上传失败",@"URL",kDetectUrl,error);
                failureBlock(error);
            } else {
                NSError *error = nil;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if (!error) {
                    //                    NSLog(@"upload success：%@", dic);
                    successBlock(dic);
                } else {
//                    ZHJLog(@"数据解析失败",@"URL",kDetectUrl,error);
                    failureBlock(error);
                }
            }
        });
    }];
    //执行任务
    [uploadTask resume];
}

#pragma mark: -- 字典转json
+(NSString *)convertToJsonData:(NSDictionary *)dict {
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

#pragma mark 请求参数打印
+(void)printParamSeting:(NSDictionary*)dic task:( NSURLSessionDataTask * _Nullable )task response:(id)responseObject {
    //    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    //    NSDictionary *dictemp = @{@"URL":response.URL.absoluteString,@"param":dic,@"header":response.allHeaderFields,@"response":responseObject};
    //    NSLog(@"请求内容:%@",dictemp);
}

#pragma mark 报错信息
/**
 处理报错信息
 
 @param error AFN返回的错误信息
 @param task 任务
 @return description
 */
+(NSString *)failHandleWithErrorResponse:( NSError * _Nullable )error task:( NSURLSessionDataTask * _Nullable )task {
    //    __block NSString *message = nil;
    //    // 这里可以直接设定错误反馈，也可以利用AFN 的error信息直接解析展示
    //    NSData *afNetworking_errorMsg = [error.userInfo objectForKey:NetworkingOperationFailingURLResponseDataErrorKey];
    //    NSLog(@"afNetworking_errorMsg == %@",[[NSString alloc]initWithData:afNetworking_errorMsg encoding:NSUTF8StringEncoding]);
    //    if (!afNetworking_errorMsg) {
    //        message = @"网络连接失败";
    //    }
    //    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    //    NSInteger responseStatue = response.statusCode;
    //    if (responseStatue >= 500) {  // 网络错误
    //        message = @"服务器维护升级中,请耐心等待";
    //    } else if (responseStatue >= 400) {
    //        // 错误信息
    //        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:afNetworking_errorMsg options:NSJSONReadingAllowFragments error:nil];
    //        message = responseObject[@"error"];
    //    }
    //    NSLog(@"error == %@",error);
    //    return message;
    return @"";
}

@end



