//
//  OCViewController.h
//  OC_Extend
//
//  Created by zhj1214 on 05/10/2018.
//  Copyright (c) 2018 zhj1214. All rights reserved.
//

@import UIKit;
#import "TestMethodSwizzling.h"
#import <MGSwipeTableCell/MGSwipeTableCell.h>
//#import <MGSwipeTableCell/MGSwipeButton.h>

@interface OCViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;

@end
