//
//  StatusBarNavBarViewController.h
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/24/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusBarNavBarViewController : UIViewController {
@protected
	BOOL didBeginDrag;
	BOOL statusBarHidden;
}

- (void)toggleStatusBarNavBarVisibility;

- (void)moveBoxByOffset:(CGFloat)offset;
- (void)moveBoxWithVelocity:(CGPoint)velocity animatedWithCompletion:(void (^__nullable)(BOOL b))completion;
- (UIView *__nonnull)statusBarNavBarView;

@end
