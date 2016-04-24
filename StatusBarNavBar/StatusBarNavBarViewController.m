//
//  StatusBarNavBarViewController.m
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/24/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import "StatusBarNavBarViewController.h"

@implementation StatusBarNavBarViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.statusBarNavBarView.hidden = YES;
	self.statusBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshStatusBarNavBarView];
}

- (void)toggleStatusBarNavBarVisibility {
	if ([self navigationController]) {
		if ([[self navigationController] isNavigationBarHidden] == NO) {
			[self refreshStatusBarNavBarView];
			self.statusBarNavBarView.hidden = NO;
			[self.navigationController setNavigationBarHidden:YES animated: NO];
			self.statusBarHidden = YES;
			[self moveBoxMinLowAnimatedWithCompletion:^(BOOL b) {
			
			}];
		} else if ([[self navigationController] isNavigationBarHidden] == YES) {
			self.statusBarNavBarView.hidden = NO;

			[self.navigationController setNavigationBarHidden:NO animated: YES];
			[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
			[self setNeedsStatusBarAppearanceUpdate];
			[self moveBoxMaxHighAnimatedWithCompletion:^(BOOL b) {
				self.statusBarHidden = NO;
//				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//					self.statusBarNavBarView.hidden = YES;
//				});
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
	return -([self navBarHeight]) - [self statusBarHeight];
}

- (CGFloat)statusBarHeight {
	return 20;
}

- (CGFloat)navBarHeight {
	return self.navigationController.navigationBar.frame.size.height;
}

- (void)moveBoxByOffset:(CGFloat)offset {
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
			self.statusBarHidden = YES;
			
		} else { // down
			NSLog(@"down");
		}
	}
}

- (void)moveBoxWithVelocity:(CGPoint)velocity animatedWithCompletion:(void (^)(BOOL b))completion {
	NSLog(@"velocity %@", @(velocity.y));
	NSTimeInterval time = 0.7;
	CGFloat initialSpringVelocity = velocity.y / (self.highLimitY - self.lowLimitY);
	if (0 <= fabsf(velocity.y) && fabsf(velocity.y) < 0.1) {
		// force it in a specific direction
		CGFloat currY = self.statusBarNavBarView.frame.origin.y;
		if (((self.highLimitY + self.lowLimitY)/2) <= currY && currY <= self.highLimitY) {
			[self moveBoxMaxHighAnimatedWithCompletion:^(BOOL b) {
				[self.navigationController setNavigationBarHidden:NO animated:NO];
				self.statusBarHidden = NO;
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self refreshStatusBarNavBarView];
				});

				completion(b);
			}];
		} else {
			[self moveBoxMinLowAnimatedWithCompletion:^(BOOL b) {
				[self.navigationController setNavigationBarHidden:YES animated:NO];
				self.statusBarHidden = YES;
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
							 if (velocity.y < 0) { // down
								 self.statusBarHidden = NO;
								 [self.navigationController setNavigationBarHidden:NO animated:NO];
								 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
									 self.statusBarNavBarView.hidden = YES;
								 });
							 }
							 completion(b);
						 }];
	}
}

/**move origin to most positive y position*/
- (void)moveBoxMaxHighAnimatedWithCompletion:(void (^)(BOOL b))completion {
	[self moveBoxWithVelocity:CGPointMake(0, -(self.highLimitY - self.lowLimitY))
	   animatedWithCompletion:completion];
}

/**move origin to most negative y position*/
- (void)moveBoxMinLowAnimatedWithCompletion:(void (^)(BOOL b))completion {
	[self moveBoxWithVelocity:CGPointMake(0, (self.highLimitY - self.lowLimitY))
	   animatedWithCompletion: completion];
}

- (UIView *__nonnull)statusBarNavBarView {
	static UIView *__view = nil;
	
	if (__view == nil) {
		UIImageView *view = [[UIImageView alloc] init];
		view.tag = 123;
		view.backgroundColor = [UIColor blueColor];
		CGRect frame = [[[self navigationController] navigationBar] bounds];
		frame.size.height += [self statusBarHeight];
		view.frame = frame;
		UIWindow *window = [[UIWindow alloc] initWithFrame:view.bounds];
//		window.frame = CGRectOffset(window.frame, 100, 0);//debug
		[window addSubview:view];
		window.hidden = NO;
		window.windowLevel = UIWindowLevelAlert + 1;
		__view = window;
		if ([[self navigationController] isNavigationBarHidden] == YES) {
			// window begins off screen
			CGRect frame = window.frame;
			frame.origin.y = self.lowLimitY;
			window.frame = frame;
		} else {
			[self refreshStatusBarNavBarView];
		}
	}
	return __view;
}

/**Use this right before you hide nav and status*/
- (void)refreshStatusBarNavBarView {
	UIImageView *imgView = [[self statusBarNavBarView] viewWithTag:123];
	[imgView setImage:[self takeImageOfStatusBarNavBarRegion]];
}

- (UIImage *)takeImageOfStatusBarNavBarRegion {	
	CGFloat statusBarHeight = 20.0;
	UIScreen *screen = [UIScreen mainScreen];
	UIView *snapshotView = [screen snapshotViewAfterScreenUpdates:true];
	CGRect statusNavBarFrame = snapshotView.bounds;
	statusNavBarFrame.size.height = statusBarHeight + self.navigationController.navigationBar.frame.size.height;
	UIGraphicsBeginImageContextWithOptions(statusNavBarFrame.size, true, 0);
	[snapshotView drawViewHierarchyInRect:snapshotView.bounds afterScreenUpdates: true];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (void)setStatusBarHidden:(BOOL)newVal {
	if (self->statusBarHidden != newVal) {

		self->statusBarHidden = newVal;
		[[UIApplication sharedApplication] setStatusBarHidden:newVal animated:NO];
		[self setNeedsStatusBarAppearanceUpdate];
	}
}

@end
