//
//  ZhjLocation.m
//  TDXApp
//
//  Created by 红军张 on 2017/7/24.
//  Copyright © 2017年 chenliang. All rights reserved.
//

#import "ZhjLocation.h"


@interface ZhjLocation () <CLLocationManagerDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation ZhjLocation

static ZhjLocation *share;

#pragma mark --  创建类单利
+(ZhjLocation*)shareZHJLocation {
    static dispatch_once_t oncetoken;
    dispatch_once(&oncetoken, ^{
        if (share == nil) {
            share = [[ZhjLocation alloc] initWithTypeDefault];
        }
    });
    return share;
}

- (instancetype)initWithTypeDefault {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        // 设置定位精确度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 设置过滤器为无
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        //ios8以上版本使用。
        [self.locationManager requestWhenInUseAuthorization];
    }
    return self;
}

#pragma mark - 开始定位
- (void)beginUpdatingLocation {
    [self.locationManager startUpdatingLocation];
}

#pragma mark - 停止定位
-(void)stopLocation{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - 定位失败  或者  用户选择不允许回调
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打开定位开关" message:@"定位服务未开启，请进入系统［设置］> [隐私] > [定位服务]中打开开关，并允许使用定位服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即开启", nil];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *version = [UIDevice currentDevice].systemVersion;
        if ([version floatValue] >= 10) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
        } else {
            NSURL* url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication]openURL:url];
            }
        }
    }
}
#pragma mark - location delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    //获取新的位置
    CLLocation * newLocation = locations.lastObject;
    
    //创建自定制位置对象
    Location * location = [[Location alloc] init];
    
    //存储经度
    location.longitude = newLocation.coordinate.longitude;
    
    //存储纬度
    location.latitude = newLocation.coordinate.latitude;
    
    //根据经纬度反向地理编译出地址信息
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks.count > 0) {
            CLPlacemark * placemark = placemarks.firstObject;
            //存储位置信息
            location.country = placemark.country;
            location.administrativeArea = placemark.administrativeArea;
            location.locality = placemark.locality;
            location.subLocality = placemark.subLocality;
            location.thoroughfare = placemark.thoroughfare;
            location.subThoroughfare = placemark.subThoroughfare;
            
            //设置代理方法
            if ([self.delegate respondsToSelector:@selector(locationDidEndUpdatingLocation:)]) {
                [self.delegate locationDidEndUpdatingLocation:location];
            }
        }
    }];
}


@end
