//
//  StatusBarNavBarViewController.h
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/24/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusBarNavBarViewController : UIViewController {
@protected BOOL didBeginDrag;
}

- (void)toggleStatusBarNavBarVisibility;

- (void)moveBoxByOffset:(CGFloat)offset;
- (void)moveBoxWithVelocity:(CGPoint)velocity animatedWithCompletion:(void (^)(BOOL b))completion;
/**move origin to most negative y position*/
- (void)moveBoxMinLowAnimatedWithCompletion:(void (^)(BOOL b))completion;
	
/**move origin to most positive y position*/
- (void)moveBoxMaxHighAnimatedWithCompletion:(void (^)(BOOL b))completion;
		

@end
