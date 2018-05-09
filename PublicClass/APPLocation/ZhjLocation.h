//
//  ZhjLocation.h
//  TDXApp
//
//  Created by 红军张 on 2017/7/24.
//  Copyright © 2017年 chenliang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Location.h"

@protocol ZhjLocationDelegate <NSObject>

-(void)locationDidEndUpdatingLocation:(Location *)location;
@end

@interface ZhjLocation : NSObject

@property (nonatomic, weak) id<ZhjLocationDelegate> delegate;

+(ZhjLocation*)shareZHJLocation;

-(void)stopLocation;

-(void)beginUpdatingLocation;

@end


