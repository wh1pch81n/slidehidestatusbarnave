//
//  StatusBarNavBarViewController.h
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/24/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StatusBarSwizzleDelegate
@property (nonatomic, assign) BOOL statusBarHidden;
- (BOOL)prefersStatusBarHidden;
@end

@interface StatusBarNavBarViewController : UIViewController <StatusBarSwizzleDelegate> {
@protected BOOL didBeginDrag;
}

- (void)toggleStatusBarNavBarVisibility;

- (void)moveBoxByOffset:(CGFloat)offset;
- (void)moveBoxWithVelocity:(CGPoint)velocity animatedWithCompletion:(void (^)(BOOL b))completion;

@end
