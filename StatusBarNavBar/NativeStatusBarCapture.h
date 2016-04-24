//
//  NativeStatusBarCapture.h
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/23/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusBarNavBarViewController.h"

@interface NativeStatusBarCapture : StatusBarNavBarViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *imageStatus;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
