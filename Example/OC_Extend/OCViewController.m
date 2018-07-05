//
//  OCViewController.m
//  OC_Extend
//
//  Created by zhj1214 on 05/10/2018.
//  Copyright (c) 2018 zhj1214. All rights reserved.
//

#import "OCViewController.h"
#import <GBDeviceInfo/GBDeviceInfo.h>
#import "ZHJLabel.h"
#import <AFNetworking/AFNetworking.h>
// 使用model
#import "WeatherInfoTestModel.h"
// 自己封装的请求
#import "XMNetWorkHelper.h"

//hock
#import <Aspects/Aspects.h>
//
#import "TestNSURLSessionTask.h"

@interface OCViewController ()

@property(nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    


    
//#ifdef __IPHone_11_0
    
//#endif
    
    [self getDeviceIPAddress];
    
    [self initData];
}
#pragma mark -- 初始化数据源
-(void)initData {
    self.table.rowHeight = UITableViewAutomaticDimension;
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"label 绘制文字图层"];
    [array addObject:@"runtime 练习"];
    [array addObject:@"AFN请求网络"];
    [array addObject:@"custom网络类 请求"];
    [array addObject:@"网络监听"];
    [self.dataArray addObject:array];
    [self.dataArray addObject:@[@"测试NSURLSessionTask使用"]];
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    view.backgroundColor = [UIColor grayColor];
    
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"第%ld区",(long)section];
    label.center = view.center;
    label.bounds = CGRectMake(0, 0, 100, 35);
    label.textColor = [UIColor redColor];
    [view addSubview:label];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = self.dataArray[indexPath.section];
    static NSString *indentifier = @"cells";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:indentifier];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.detailTextLabel.text = @"你好啊小军";
    } else {
        cell.detailTextLabel.text = array[indexPath.row];
    }
    
    cell.delegate = self;
    cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"left" backgroundColor:[UIColor redColor]]];
    
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
 
    
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]],
                          [MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;

    
    return cell;
}

//- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self.arrayTest removeObjectAtIndex:indexPath.row];
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }];
//    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self.arrayTest exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
//        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
//        [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
//    }];
//    topRowAction.backgroundColor = [UIColor blueColor];
//    UITableViewRowAction *moreRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"更多" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
//    }];
//    return @[deleteRowAction,topRowAction,moreRowAction];
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:{
                    [Tool drawText:cell.textLabel];
                    [ZHJAlertViewController alertShowTitle:@"welcome browse" message:[NSString stringWithFormat:@"实际label的文字是：%@",cell.textLabel.text] cancelButtonTitle:@"承认" otherButtonTitles:@"对" block:^(NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            NSLog(@"有意思");
                        } else {
                            NSLog(@"你好");
                        }
                    }];
                }
                    break;
                case 1:
                    [self testMethodSwizzling];
                    break;
                case 2:
                    [self testNetWorkingModel];
                    break;
                case 3:
                    [self initAccountFuntion];
                    break;
                case 4:
                    [self networkingMonitoring];
                    break;
            }
            break;
        case 1:{
            UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TestNSURLSessionTask *VC = [board instantiateViewControllerWithIdentifier:@"SessionTask"];
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
            
        default:
            NSLog(@"还有这情况啊");
            break;
    }
}


#pragma mark -- 网络监听
-(void)networkingMonitoring {
    // 请求拦截
    //    [CustomHTTPProtocol registerInterceptor];
    
    NSError *error = nil;
    [NSURLSession aspect_hookSelector:@selector(dataTaskWithRequest:completionHandler:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        for (id obj in info.arguments) {
            if ([obj isKindOfClass:[NSURLRequest class]]) {
                NSURLRequest *request = (NSURLRequest*)obj;
                if (request.URL) {
                    NSString *body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
                    NSLog(@"链接是 ————%@___请求内容__%@",request.URL.absoluteString,body);
                }
            }
        }
    } error:&error];
    if (error) {
        NSLog(@"_hock 失败______%@",error);
    } else {
        [self testNetWorkingModel];
    }
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

#pragma mark: -- TestMethodSwizzling
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

#pragma mark: -- TestNetWorking
-(void)testNetWorkingModel {
    [[ZHJNetworkManager defaultManager] sendRequestMethod:HTTPMethodGET apiPath:@"http://www.weather.com.cn/data/sk/101010100.html" parameters:nil hud:YES cache:NO progress:nil success:^(BOOL isSuccess, id  _Nullable responseObject) {
        WeatherInfoTestModel *weather = [WeatherInfoTestModel yy_modelWithJSON:responseObject[@"weatherinfo"]];
        NSLog(@"成功__城市%@",weather.cityName);
    } failure:^(NSString * _Nullable errorMessage) {
        NSLog(@"失败");
    }];
}

-(void)initAccountFuntion {
    NSDictionary *dictemp = @{@"sdkIP":@"ssdsadweasdasdsc_test",@"applicationID":@"dsgfslkcnah37teiw_test",@"sdkType":@"iOS",@"appID":@"0f89cfb8_8bb9_4017_b54d_5e7c32f28a42",@"sdkVersion":@"SDK1.0.0",@"sdkOsVersion":@"znxcnahsda_test",@"sdkDesc":@"鑫云+外联开放平台",@"sdkImei":@"dkasndasdmdas_test"};
    NSString *data_Str = [Tool convertToJsonData:dictemp];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:data_Str forKey:@"data"];
    
    [XMNetWorkHelper postWithUrlString:@"/getAuthPlantSignData" parameters:dic success:^(NSDictionary *data) {
        NSLog(@"成功  %@",data);
    } failure:^(NSError *error) {
        NSLog(@"失败 %@",error);
    }];
}

#pragma mark: -- private
-(NSMutableArray*)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) swipeTableCell:(nonnull MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    if (direction == MGSwipeDirectionLeftToRight) {
        
        NSLog(@"左边 index:%ld  fromExpansion ",(long)index);
    } else {
            NSLog(@"右边 index:%ld  fromExpansion",(long)index);
    }
    
    return YES;
}
@end

