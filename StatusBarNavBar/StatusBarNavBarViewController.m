//
//  StatusBarNavBarViewController.m
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/24/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import "StatusBarNavBarViewController.h"
#import <objc/runtime.h>



static UIView *statusBar = nil;
static UIViewController <StatusBarSwizzleDelegate>*swizzleDelegate = nil;

@interface UIView(View2Image)
- (UIImage *)viewToImage;
@end

@implementation UIView(View2Image)
- (UIImage *)viewToImage {
	UIView *view = self;
	UIImage *viewImage;
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
	[[view layer] renderInContext:UIGraphicsGetCurrentContext()];
	
	viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return viewImage;
}

@end

@interface UIView (SwizzleStatusBar)
+ (void)setSwizzleDelegate:(UIViewController <StatusBarSwizzleDelegate>*)delegate;
+ (UIView *)statusBar;
+ (UIImage *)statusBarImage;
@end

@implementation UIView (SwizzleStatusBar)

+ (void)setSwizzleDelegate:(UIViewController <StatusBarSwizzleDelegate>*)delegate {
	swizzleDelegate = delegate;
}


+ (UIImage *)statusBarImage {
	return [[self statusBar] viewToImage];
}
+ (UIView *)statusBar {
//	if (!statusBar) {
//		StatusBarNavBarViewController */*UIViewController <StatusBarSwizzleDelegate>*/vc =  swizzleDelegate;//[self currentUserFacingViewController];
//		[self swapTransformWithStatusTransform];
//		NSLog(@"1%@", @(vc.statusBarHidden));
//		[vc setStatusBarHidden:!vc.statusBarHidden];
//		[vc setNeedsStatusBarAppearanceUpdate];
//		NSLog(@"2%@", @(vc.statusBarHidden));
//		[vc setStatusBarHidden:!vc.statusBarHidden];
//		[vc setNeedsStatusBarAppearanceUpdate];
//		NSLog(@"3%@", @(vc.statusBarHidden));
//		[self swapTransformWithStatusTransform];
//		swizzleDelegate = nil;
//	}
	return statusBar;
}
+ (void)swapTransformWithStatusTransform {
	SEL origImplmentation = @selector(setTransform:);
	SEL swizzledImplementation = @selector(setStatusBarTransform:);
	
	Method origMethod = class_getInstanceMethod(UIView.class, origImplmentation);
	Method swizzledMethod = class_getInstanceMethod(UIView.class, swizzledImplementation);
	
	method_exchangeImplementations(
								   origMethod,
								   swizzledMethod
								   );
}
- (void)setStatusBarTransform:(CGAffineTransform)transform {
	NSAssert([self isKindOfClass:NSClassFromString(@"UIStatusBar")], @"Expected Status Bar");
	statusBar = self;
}

@end

@implementation StatusBarNavBarViewController
@synthesize statusBarHidden;

- (void)viewDidLoad {
	[super viewDidLoad];
	if (![UIView statusBar]) {
		[UIView swapTransformWithStatusTransform];
		NSLog(@"1%@", @(self.statusBarHidden));
		[self setStatusBarHidden:!self.statusBarHidden];
		[self setNeedsStatusBarAppearanceUpdate];
		NSLog(@"2%@", @(self.statusBarHidden));
		[self setStatusBarHidden:!self.statusBarHidden];
		[self setNeedsStatusBarAppearanceUpdate];
		NSLog(@"3%@", @(self.statusBarHidden));
		[UIView swapTransformWithStatusTransform];
	}
	
//	[UIView setSwizzleDelegate:self];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.statusBarNavBarView.hidden = YES;
	self.statusBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
//	[self refreshStatusBarNavBarView];
}

- (BOOL)prefersStatusBarHidden {
	return self.statusBarHidden;
}

- (void)toggleStatusBarNavBarVisibility {
	if ([self navigationController]) {
		if ([[self navigationController] isNavigationBarHidden] == NO) {
			[self refreshStatusBarNavBarView];
			self.statusBarNavBarView.hidden = NO;
			[self.navigationController setNavigationBarHidden:YES animated: NO];
			self.statusBarHidden = YES;
			[self setNeedsStatusBarAppearanceUpdate];
			[self moveBoxMinLowAnimatedWithCompletion:^(BOOL b) {
			
			}];
		} else if ([[self navigationController] isNavigationBarHidden] == YES) {
			[self moveBoxMaxHighAnimatedWithCompletion:^(BOOL b) {
				[self.navigationController setNavigationBarHidden:NO animated: NO];
				self.statusBarHidden = NO;
				[self setNeedsStatusBarAppearanceUpdate];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					self.statusBarNavBarView.hidden = YES;
				});
				[self refreshStatusBarNavBarView];
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
//			[self refreshStatusBarNavBarView];
			[self.navigationController setNavigationBarHidden:YES animated:NO];
			self.statusBarHidden = YES;
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
				self.statusBarHidden = NO;
				[self setNeedsStatusBarAppearanceUpdate];
				completion(b);
			}];
		} else {
			[self moveBoxMinLowAnimatedWithCompletion:^(BOOL b) {
				[self.navigationController setNavigationBarHidden:YES animated:NO];
				self.statusBarHidden = YES;
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
	
	// Swap with image later
	if (__view == nil) {
		UIImageView *view = [[UIImageView alloc] init];
		view.tag = 123;
		view.backgroundColor = [UIColor blueColor];
		CGRect frame = [[[self navigationController] navigationBar] bounds];
		frame.size.height += [self statusBarHeight];
		view.frame = frame;
		UIWindow *window = [[UIWindow alloc] initWithFrame:view.bounds];
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
	CGRect statusBarRect = CGRectMake(0, 0, [UIView statusBar].frame.size.width, [self statusBarHeight]);
	CGRect navBarRect = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, [self navBarHeight]);
	navBarRect.origin.y = CGRectGetMaxY(statusBarRect);
	CGRect statusNavBarFrame = CGRectMake(0, 0, CGRectGetWidth(statusBarRect), CGRectGetHeight(statusBarRect) + CGRectGetHeight(navBarRect));
	UIGraphicsBeginImageContextWithOptions(statusNavBarFrame.size, true, 0);
	[[UIView statusBar] setBackgroundColor:[self colorOfNavBar]];
	[[UIView statusBarImage] drawInRect:statusBarRect];
	[[self.navigationController.navigationBar viewToImage] drawInRect:navBarRect];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (UIColor *)colorOfNavBar {
	CGRect dot = CGRectMake(0, 0, 1, 1);
	CGImageRef drawImage = CGImageCreateWithImageInRect([self.navigationController.navigationBar viewToImage].CGImage, dot);
	UIColor *color = [UIColor colorWithPatternImage:[UIImage imageWithCGImage:drawImage]];
	return color;
}

@end
