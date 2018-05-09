//
//  ConfusionCoding.m
//  encryptionTest
//
//  Created by 红军张 on 2018/4/13.
//  Copyright © 2018年 SLAuthentication. All rights reserved.
//

#import "ConfusionCoding.h"
#import "CipherData.h"
//#import "ZHJNetworkManager.h"

#define strData @"0.45055485242947646,0.8693947344595863,0.2847442796345079,0.5494451475705235|PV+Z04mDndhUopCm7RYcAg==|X6u1xFHanXpL/R90/Ndw6Q=="

#define randomData @"870273998317644119,4738806068657599003,4691063345513595205,5528584045551686832,7685803963588986629,4015399755973081519,496678930375822035,6002490994764403931,4040373527993476900,4208403529892558397,8021566416859490109,2280240260709248902,3642445960412013344,2206993397323983838,1445845357343905683,8544952870191816307,7001050889746927441,2048916435273528426,6234536385947089998,2978514340143231064,4584140213369982347,9218586458943696777,8962827798615125457,1018153854273564677,6906793506716422281,2679018100835556849,1314553610796009617,2658954425303997673,1276912065606701675,3342557243467077894,3186182513241980127,1176986136794333056"

#define column 8

@interface ConfusionCoding()

// 混淆 key
@property(nonatomic,copy) NSString *key;

// 混淆 偏移量
@property(nonatomic,copy) NSString *iv;

// 混淆 矩阵 分割后的矩阵
@property(nonatomic,strong) NSMutableArray *dataArray;

// 混淆 random 分割后的数组
@property(nonatomic,strong) NSMutableArray *randomDataArray;

// 混淆 规则
@property(nonatomic,copy) NSString *rules;

// 混淆 random
@property(nonatomic,copy) NSString *random;

// app-user
@property(nonatomic,copy) NSString *app_user;

// date
@property(nonatomic,copy) NSString *date;

// 代存 混淆 token
@property(nonatomic,copy) NSString *token;

// 混淆规则 初始化是否成功
@property(nonatomic,assign) BOOL isReady;

@end

@implementation ConfusionCoding

#pragma mark -- 单利
static ConfusionCoding *object;

+(ConfusionCoding*)defaultmanger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (object == nil) {
            object = [[ConfusionCoding alloc] initWithTypeDefault];
        }
    });
    return object;
}

-(instancetype)initWithTypeDefault {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark -- 初始化API
+(void)initCommunicationStrengthenSDK:(NSDictionary*)dictionary callBack:(Success)block {
    if (dictionary.allKeys.count<1) {return block(NO,@"参数不正确");}
    [ConfusionCoding defaultmanger].token = dictionary[@"token"];
    [ConfusionCoding defaultmanger].app_user = dictionary[@"app-user"];
    [ConfusionCoding defaultmanger].date = dictionary[@"date"];
    
//    [[ZHJNetworkManager defaultManager] sendRequestMethod:HTTPMethodPUT apiPath:@"/query/getRules" parameters:dictionary progress:nil success:^(BOOL isSuccess, id  _Nullable responseObject) {
//        BOOL isok = [[responseObject objectForKey:@"resultFlag"] boolValue];
//        if (isok) {
//            NSString *rule = [responseObject objectForKey:@"rule"];
//            NSString *random = [responseObject objectForKey:@"random"];
//            if (rule.length >0 && random.length >0) {
//                [ConfusionCoding defaultmanger].rules = rule;
//                [ConfusionCoding defaultmanger].random = random;
//                if (![[ConfusionCoding defaultmanger] parsingData]) {
//                    [ConfusionCoding defaultmanger].isReady = NO;
//                    NSLog(@"规则 解析失败");
//                    block(NO,@"混淆规则不正确");
//                } else {
//                    [ConfusionCoding defaultmanger].isReady = YES;
//                    block(YES,@"success");
//                }
//            } else {
//                block(NO,@"服务异常,请重试");
//            }
//        } else {
//            block(NO,[responseObject objectForKey:@"infor"]);
//        }
//    } failure:^(NSString * _Nullable errorMessage) {
//        block(NO,errorMessage);
//        NSLog(@"/api/getRules 请求失败 %@",errorMessage);
//    }];
}

#pragma mark -- 校验混淆规则
-(BOOL)parsingData {
    if (self.random.length<1||self.rules.length<1) {return NO;}
    NSArray *array = [self.rules componentsSeparatedByString:@"|"];
    self.dataArray = (NSMutableArray*)[array[0] componentsSeparatedByString:@","];
    self.key = array[1];
    self.iv = array[2];
    
    NSArray *random = [self.random componentsSeparatedByString:@","];
    self.randomDataArray = [[NSMutableArray alloc] init];
    NSMutableArray *minArray;
    for (int i = 0; i<random.count; i++) {
        if (i%8 == 0) {
            minArray= [NSMutableArray array];
        }
        [minArray addObject:random[i]];
        if (minArray.count == column) {
            [self.randomDataArray addObject:minArray];
        }
    }
    return (self.dataArray.count == 4 && random.count == 32);
}

#pragma mark -- 对原始数据 混淆/解混淆
+(NSMutableDictionary*)getMixToNumberData:(NSMutableDictionary*)dic isCoding:(BOOL)coding {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (dic.allKeys.count < 1 || ![ConfusionCoding defaultmanger].isReady) {
        return dictionary;
    }  
    NSString *strSchemas = @"";
    for (NSString *key in dic.allKeys) {
        NSString *data = coding ? [[ConfusionCoding defaultmanger] applyToNumber:key] : [[ConfusionCoding defaultmanger] recoverToNumber:key];
        if (data) {
            [dictionary setObject:data forKey:key];
        }
        [strSchemas stringByAppendingString:[NSString stringWithFormat:@",%@",key]];
    }
    [[ConfusionCoding defaultmanger] statisticalMixData:strSchemas type:coding?@"distortion":@"recover" results:dic.allKeys.count == dictionary.allKeys.count? @"successful" :@"failure"];
    return dictionary;
}
-(NSString*)applyToNumber:(NSString*)number {
    
    if (self.dataArray.count != 4) {return @"";}
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i<self.dataArray.count; i++) {
        NSDecimalNumber *xxx = [NSDecimalNumber decimalNumberWithString:self.dataArray[i]];
        NSDecimalNumber *yyy = [NSDecimalNumber decimalNumberWithString:number];
        xxx = [xxx decimalNumberByMultiplyingBy:yyy];
        [array addObject:[self ena:xxx i:(i+1)encryption:YES]];
    }
    NSString *results = @"";
    for (NSString *str in array) {
        if (results.length>0) {
            results = [results stringByAppendingString:[NSString stringWithFormat:@",%@",str]];
        } else {
            results = [results stringByAppendingString:str];
        }
    }
    return results;
}

-(NSString*)recoverToNumber:(NSString*)number {
    if (number.length<4) {return @"";}
    NSArray *array = [number componentsSeparatedByString:@","];
    if (array.count !=4) {return @"";}
    if (self.randomDataArray.count == 4) {
        NSString *a1 = [self ena:[NSDecimalNumber decimalNumberWithString:array[0]] i:1 encryption:NO];
        NSString *a4 = [self ena:[NSDecimalNumber decimalNumberWithString:array[3]] i:4 encryption:NO];
        return [NSString stringWithFormat:@"%f",[a1 doubleValue] + [a4 doubleValue]];
    } else {
        return [NSString stringWithFormat:@"%f",[array[0] doubleValue] + [array[3] doubleValue]];
    }
}

#pragma mark -- 字符串 加密/解密
+(NSMutableDictionary*)getMixToStringData:(NSMutableDictionary*)dic isCoding:(BOOL)coding {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (dic.allKeys.count < 1 || ![ConfusionCoding defaultmanger].isReady) {
        return dictionary;
    }
    NSString *strSchemas = @"";
    for (NSString *key in dic.allKeys) {
        NSString *data = coding ? aesEncryptString(key, [ConfusionCoding defaultmanger].key, [ConfusionCoding defaultmanger].iv) : aesDecryptString(key, [ConfusionCoding defaultmanger].key, [ConfusionCoding defaultmanger].iv);
        if (data) {
            [dictionary setObject:data forKey:key];
        }
        [strSchemas stringByAppendingString:[NSString stringWithFormat:@",%@",key]];
    }
    
    [[ConfusionCoding defaultmanger] statisticalMixData:strSchemas type:coding?@"distortion":@"recover" results:dic.allKeys.count == dictionary.allKeys.count? @"successful" :@"failure"];
    return dictionary;
}


#pragma mark -- 统计接口
-(void)statisticalMixData:(NSString*)mixSchemas type:(NSString*)type results:(NSString*)results {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[ConfusionCoding defaultmanger].app_user forKey:@"app-user"];
    [dictionary setObject:[ConfusionCoding defaultmanger].token forKey:@"token"];
    [dictionary setObject:[ConfusionCoding defaultmanger].date forKey:@"date"];
    [dictionary setObject:mixSchemas forKey:@"schemas"];
    [dictionary setObject:type forKey:@"operation-type"];
    [dictionary setObject:results forKey:@"result"];
    
//    [[ZHJNetworkManager defaultManager] sendRequestMethod:HTTPMethodPUT apiPath:@"/query/statistic/distortion" parameters:dictionary progress:nil success:^(BOOL isSuccess, id  _Nullable responseObject) {
//        BOOL isok = [[responseObject objectForKey:@"resultFlag"] boolValue];
//        if (!isok) {
//            NSLog(@"%@", [responseObject objectForKey:@"infor"]);
//        }
//    } failure:^(NSString * _Nullable errorMessage) {
//        NSLog(@"/api/getRules 请求失败 %@",errorMessage);
//    }];
}

#pragma mark --  混淆规则
-(NSString*)ena:(NSDecimalNumber*)a i:(int)i encryption:(BOOL)isok {
    if (i < 1 || i > 4 || self.randomDataArray.count != 4){return @"";}
    i -= 1;
    NSString *t = self.randomDataArray[i][0];
    long long b = [t longLongValue];
    for (int m = 0; m < column - 1; m++) {
        long long aa = [self.randomDataArray[i][m + 1] longLongValue];
        b = b^aa;
    }
    //protect zero
    if (b == 0) {
        b = [self.randomDataArray[i][3] longLongValue];
    }
    
    t = [NSString stringWithFormat:@"%lld",b];
    if (t.length>8) {
        t = [t substringToIndex:8];
    }
    
    NSDecimalNumber *x = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"0.%@",t]];
    NSDecimalNumber *results;
    if (isok) {
        //    while (x < 0.1) {
        //        x *= 10;
        //    }
        results = [a decimalNumberByDividingBy:x];
    } else {
        results = [a decimalNumberByMultiplyingBy:x];
    }
    
    return results.stringValue;
}

@end
