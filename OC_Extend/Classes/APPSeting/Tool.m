//
//  Tool.m
//  testAPP
//
//  Created by 红军张 on 2018/3/26.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import "Tool.h"
#import <UIKit/UIKit.h>

// 加密
#import <CommonCrypto/CommonCrypto.h>
// ip
#import <ifaddrs.h>
#import <arpa/inet.h>
//SAMKeychain
#import "SAMKeychain.h"

#define keyChainUser @"ZBSLKEYS"
#define keyChainUserServer @"ZBSLKEYSServer"
#define keyChainDeveiceUUIDKey @"DevilUUID"

// 获取手机ip
#import "IPToolManager.h"

@implementation Tool

#pragma mark: -- 异步执行代码块（主队列执行）
+(void)async:(void (^)(void))mainTask {
    dispatch_async(dispatch_get_main_queue(), mainTask);
}

#pragma mark: -- 异步执行代码块（先非主线程执行，再返回主线程执行）
+(void)async:(void (^)(id ii))backgroundTask mainTask:(void (^)(id i))mainTask {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        backgroundTask(@"开始执行");
        dispatch_sync(dispatch_get_main_queue(), ^{
            mainTask(@"主线程");
        });
    });
}

#pragma mark: -- 回到主线程执行
+(void)getMainQueu:(void (^)(void))mainTask {
    dispatch_async(dispatch_get_main_queue(), ^{
        mainTask();
    });
}

#pragma mark: -- 系统延迟方法 不可取消 延迟执行
+(void)delayStarFuntionSystem:(SEL)action time:(NSTimeInterval)time {
    [self performSelector:action withObject:nil afterDelay:time];
}

+(void)delayStarFuntionGCD:(NSTimeInterval)time block:(void (^)(void))action {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), action);
}


#pragma mark: -- 获取手机设备信息
+(NSString*)getPhoneDeviceInfo {
    NSString *ip = [Tool getIPAddress];
    if (ip.length<1) {ip = @"";}
    
    NSDictionary *dicTemp = @{
                              @"applicationID":[Tool getSDKApplicationID],
                              @"sdkDesc":@"鑫云+外联开放平台",
                              @"sdkIP":ip,
                              @"sdkImei":[Tool getUserUUID],
                              @"sdkOsVersion":[Tool getSystemVersion],
                              @"sdkType":@"iOS",
                              @"sdkVersion":@"SDK1.0.0"};
    NSString *errorInfo = @"";
    if ([Tool getSDKApplicationID].length < 1) {
        errorInfo = @"getSDKApplicationID：nil";
    } else if (ip.length < 1) {
        errorInfo = @"IP地址：nil";
    } else if ([Tool getUserUUID].length < 1) {
        errorInfo = @"getSDKUUID：nil";
    } else if ([Tool getSystemVersion].length < 1) {
        errorInfo = @"getSDKOsVersion：nil";
    }
    if (errorInfo.length>0) {
        NSLog(@"%@",errorInfo);
    }
    
    NSLog(@"%@",[Tool convertToJsonData:dicTemp]);
    return [Tool convertToJsonData:dicTemp];
}

#pragma mark: -- SHA1加密
+(NSString *)signWithSHA1:(NSString *)input{
    const char *cStr = [input UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (CC_LONG)strlen(cStr), result);
    NSString *str_SHA1 = [NSString  stringWithFormat:
                          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          result[0], result[1], result[2], result[3], result[4],
                          result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11], result[12],
                          result[13], result[14], result[15],
                          result[16], result[17], result[18], result[19]
                          ];
    return str_SHA1;
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

#pragma mark: -- 获取设备IP地址
+(NSString *)getIPAddress {
    IPToolManager *ipManager = [IPToolManager sharedManager];
    NSString *ip = [ipManager currentIpAddress];
    return ip.length > 0 ? ip : @"error";
}

#pragma mark: -- 获取设备Boundle ID
+(NSString*)getSDKApplicationID {
    return [[NSBundle mainBundle] bundleIdentifier];
}

#pragma mark: -- SystemVersion
+(NSString*)getSystemVersion {
    NSString *sys = [NSString stringWithFormat:@"%@-%@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
    return sys;
}

#pragma mark: -- Keychain 保存信息
+(BOOL)saveKeychaininfo:(NSString *)secret key:(NSString*)key {
    BOOL isok = [SAMKeychain setPassword:secret forService:[NSString stringWithFormat:@"%@%@",keyChainUserServer,key] account:keyChainUser];
    [SAMKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
    return isok;
}

#pragma mark: -- Keychain 读取信息
+(NSString*)takeKeychaininfoKey:(NSString*)key {
    NSString *info = [SAMKeychain passwordForService:[NSString stringWithFormat:@"%@%@",keyChainUserServer,key] account:keyChainUser];
    [SAMKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
    return info;
}

//+(void)getSAMKeychaininfo {
//    // 返回包含Keychain帐户的数组，如果Keychain没有帐户，则返回nil。
//    NSArray *allAccounts = [SAMKeychain allAccounts];
//    if (allAccounts.count>0) {
//        NSLog(@"%@", allAccounts);
//        //    返回一个数组，该数组包含给定服务的Keychain帐户，如果Keychain没有任何服务，则返回“nil”。
//        if (allAccounts.count>0) {
//            NSDictionary *dic = allAccounts.lastObject;
//            NSString *services = dic[@"svce"];
//            NSArray *ServiceArray = [SAMKeychain accountsForService:services];
//            NSLog(@"%@", ServiceArray);
//
//            //    返回一个字符串，该字符串包含给定帐户和服务的密码，如果Keychain没有，则返回“nil”。
//            //            NSString *strInfo = [SAMKeychain passwordForService:services account:dic[@"accc"]];
//            //            NSLog(@"%@", strInfo);
//            //    删除某个服务的密码
//            //            BOOL deleteIsok = [SAMKeychain deletePasswordForService:@"" account:@""];
//            //    设置某个服务的密码
//            BOOL setPasswIsok = [SAMKeychain setPassword:@"123456" forService:@"zhjserve" account:@"zhj"];
//            if (setPasswIsok) {
//                NSString *Info = [SAMKeychain passwordForService:@"zhjserve" account:@"zhj"];
//                NSLog(@"%@", Info);
//            }
//            [SAMKeychain setAccessibilityType:kSecAttrAccessibleAlwaysThisDeviceOnly];
//        }
//    }
//}

#pragma mark: -- UUID
+(NSString *)getUserUUID {
    //    先获取keychain 或 NSUserDefault 里面的UDID字段，看是否存在
    NSString *uuid = @"";
    
    NSUserDefaults *NJUserDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *uuidKeyChainStr = [Tool takeKeychaininfoKey:keyChainDeveiceUUIDKey];
    NSString *uuidUserDefaultStr = [NJUserDefault objectForKey:@"CurrentiOSSDKKey"];
    
    if (uuidKeyChainStr && uuidKeyChainStr.length!=0) {
        uuid = uuidKeyChainStr;
    } else if (uuidUserDefaultStr && uuidUserDefaultStr.length!=0){
        uuid = uuidUserDefaultStr;
    }
    
    //如果不存在则为首次获取UDID，所以获取保存,可保存在KeyChain 和 NSUserDefaults
    if (!uuid || uuid.length == 0) {
        uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
        
        //保存在Keychain里
        [Tool saveKeychaininfo:uuid key:keyChainDeveiceUUIDKey];
        
        //保存在Plist文件里
        [NJUserDefault setObject:uuid forKey:@"CurrentiOSSDKKey"];
        [NJUserDefault synchronize];
    }
    
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuid;
}

#pragma mark: -- 获取当前的时间/时间戳
+(NSString*)getCurrentTimes {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
}

//获取当前时间戳有两种方法(以秒为单位)
+(NSString *)getNowTimeTimestamp {
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return timeSp;
}
@end

