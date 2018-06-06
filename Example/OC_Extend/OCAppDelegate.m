//
//  OCAppDelegate.m
//  OC_Extend
//
//  Created by zhj1214 on 05/10/2018.
//  Copyright (c) 2018 zhj1214. All rights reserved.
//

#import "OCAppDelegate.h"

@implementation OCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 定位
    [[ZhjLocation shareZHJLocation] beginUpdatingLocation];
    
    // iphone info
//    NSLog(@"%@",[Tool getPhoneDeviceInfo]);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark: -- 获取用户 地里位置
-(void)locationDidEndUpdatingLocation:(Location *)location {
    //    NSLog(@"地理位置： %f,,,%f,,,%@,,,%@,,,%@,,,%@,,,%@,,,%@",location.latitude,location.longitude,location.country,location.administrativeArea,location.locality,location.subLocality,location.thoroughfare,location.subThoroughfare);
    // 获取经纬度
    NSString *Longitude  = [NSString stringWithFormat:@"%f",location.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%f",location.latitude];
    
    if (location.latitude && location.longitude) {
        if (location.country.length>0 && location.administrativeArea.length>0) {
            NSLog(@"经度：%@  纬度： %@",Longitude,latitude);
            [[ZhjLocation shareZHJLocation] stopLocation];
        }
    }
}
@end
