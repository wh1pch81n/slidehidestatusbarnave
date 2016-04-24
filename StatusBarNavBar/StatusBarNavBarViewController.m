//
//  StatusBarNavBarViewController.m
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/24/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import "StatusBarNavBarViewController.h"

@implementation StatusBarNavBarViewController {
	BOOL statusBarHidden;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.statusBarNavBarView.hidden = YES;
}

- (BOOL)prefersStatusBarHidden {
	return statusBarHidden;
}

- (void)toggleStatusBarNavBarVisibility {
	if ([self navigationController]) {
		if ([[self navigationController] isNavigationBarHidden] == NO) {
			self.statusBarNavBarView.hidden = NO;
			[self.navigationController setNavigationBarHidden:YES animated: NO];
			statusBarHidden = YES;
			[self setNeedsStatusBarAppearanceUpdate];
			[self moveBoxMinLowAnimatedWithCompletion:^(BOOL b) {
			
			}];
		} else if ([[self navigationController] isNavigationBarHidden] == YES) {
			[self moveBoxMaxHighAnimatedWithCompletion:^(BOOL b) {
				[self.navigationController setNavigationBarHidden:NO animated: NO];
				statusBarHidden = NO;
				[self setNeedsStatusBarAppearanceUpdate];
				self.statusBarNavBarView.hidden = YES;
			}];
		}
	}
}

/** The highest Positive y value allowed*/
- (CGFloat)highLimitY {
	return 0;
}

/**The lowest negative y value allowed*/
- (CGFloat) lowLimitY {
	return -(self.navigationController.navigationBar.frame.size.height);
}

- (void)moveBoxByOffset:(CGFloat)offset {
//	[self statusBarNavBarView].hidden = false;
	CGFloat yc = self.statusBarNavBarView.frame.origin.y + offset;
	CGRect frame = self.statusBarNavBarView.frame;
	if (yc >= [self highLimitY]) {
		frame.origin.y = self.highLimitY;
		self.statusBarNavBarView.frame = frame;
		
	} else if (yc <= self.lowLimitY) {
		frame.origin.y = [self lowLimitY];
		self.statusBarNavBarView.frame = frame;
	} else {
		frame.origin.y = yc;
		self.statusBarNavBarView.frame = frame;
		self.statusBarNavBarView.hidden = false;
		if (offset < 0) { // up
			NSLog(@"Up");
			[self.navigationController setNavigationBarHidden:YES animated:NO];
			statusBarHidden = YES;
			[self setNeedsStatusBarAppearanceUpdate];
		} else { // down
			NSLog(@"down");
		}
	}
}

- (void)moveBoxWithVelocity:(CGPoint)velocity animatedWithCompletion:(void (^)(BOOL b))completion {
	NSLog(@"velocity %@", @(velocity.y));
	NSTimeInterval time = 1.5;
	CGFloat initialSpringVelocity = velocity.y / (self.highLimitY - self.lowLimitY);
	if (0 <= fabsf(velocity.y) && fabsf(velocity.y) < 0.1) {
		// force it in a specific direction
		CGFloat currY = self.statusBarNavBarView.frame.origin.y;
		if (((self.highLimitY + self.lowLimitY)/2) <= currY && currY <= self.highLimitY) {
			[self moveBoxMaxHighAnimatedWithCompletion:^(BOOL b) {
				[self.navigationController setNavigationBarHidden:NO animated:NO];
				statusBarHidden = NO;
				[self setNeedsStatusBarAppearanceUpdate];
				completion(b);
			}];
		} else {
			[self moveBoxMinLowAnimatedWithCompletion:^(BOOL b) {
				[self.navigationController setNavigationBarHidden:YES animated:NO];
				statusBarHidden = YES;
				[self setNeedsStatusBarAppearanceUpdate];
				completion(b);
			}];
		}
	} else {
		if (velocity.y > 0) {
			// up
			CGFloat currY = self.statusBarNavBarView.frame.origin.y;
			CGFloat percent = fabsf(currY - [self lowLimitY]) / fabs([self highLimitY] - [self lowLimitY]);
			time *= percent;
		} else {
			// down
			CGFloat currY = self.statusBarNavBarView.frame.origin.y;
			CGFloat percent = fabsf(currY - [self highLimitY]) / fabs([self highLimitY] - [self lowLimitY]);
			time *= percent;
		}
		[UIView animateWithDuration:time
							  delay: 0
			 usingSpringWithDamping: 1
			  initialSpringVelocity: initialSpringVelocity
							options: UIViewAnimationOptionAllowUserInteraction
						 animations:^{
							 [self moveBoxByOffset:((self.highLimitY - self.lowLimitY) * (velocity.y < 0 ? 1 : -1))];
						 }
						 completion:^(BOOL b) {
							 completion(b);
						 }];
	}
}

- (void)moveBoxMaxHighAnimatedWithCompletion:(void (^)(BOOL b))completion {
	[self moveBoxWithVelocity:CGPointMake(0, -(self.highLimitY - self.lowLimitY))
	   animatedWithCompletion:completion];
}

- (void)moveBoxMinLowAnimatedWithCompletion:(void (^)(BOOL b))completion {
	[self moveBoxWithVelocity:CGPointMake(0, (self.highLimitY - self.lowLimitY))
	   animatedWithCompletion: completion];
}

- (UIView *__nonnull)statusBarNavBarView {
	static UIView *__view = nil;
	
	// Swap with image later
	if (__view == nil) {
		UIView *view = [[UIView alloc] init];
		view.backgroundColor = [UIColor blueColor];
		view.frame = [[[self navigationController] navigationBar] bounds];
		UIWindow *window = [[UIWindow alloc] initWithFrame:view.bounds];
		[window addSubview:view];
		window.hidden = NO;
		window.windowLevel = UIWindowLevelAlert + 1;
//		[window makeKeyAndVisible];
		__view = window;
		if ([[self navigationController] isNavigationBarHidden] == YES) {
			// window begins off screen
			CGRect frame = window.frame;
			frame.origin.y = self.lowLimitY;
			window.frame = frame;
		}
	}
	return __view;
}
@end
