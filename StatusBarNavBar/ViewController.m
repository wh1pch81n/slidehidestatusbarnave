//
//  ViewController.m
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/23/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@protocol StatusBarSwizzleDelegate
@property (nonatomic, assign) BOOL statusBarHidden;
- (BOOL)prefersStatusBarHidden;
@end

static UIView *statusBar = nil;
static __weak UIViewController <StatusBarSwizzleDelegate>*swizzleDelegate = nil;

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

//+ (UIViewController *)currentUserFacingViewController {
//	UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
//	while (vc.presentedViewController) {
//		vc = vc.presentedViewController;
//	}
//	if ([vc conformsToProtocol:@protocol(StatusBarSwizzleDelegate)]) {
//		return vc;
//	}
//	for (UIViewController *i in [vc childViewControllers]) {
//		if ([i conformsToProtocol:@protocol(StatusBarSwizzleDelegate)]) {
//			return i;
//		}
//	}
//	
//	return vc;
//}

+ (UIView *)statusBar {
	if (!statusBar) {
		UIViewController *vc =  swizzleDelegate;//[self currentUserFacingViewController];
		[self swapTransformWithStatusTransform];
		[vc setValue:@(![[UIApplication sharedApplication] isStatusBarHidden]) forKey:@"statusBarHidden"];
		[vc setNeedsStatusBarAppearanceUpdate];
		[vc setValue:@(![[UIApplication sharedApplication] isStatusBarHidden]) forKey:@"statusBarHidden"];
		[vc setNeedsStatusBarAppearanceUpdate];
		[self swapTransformWithStatusTransform];
	}
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

+ (void)swapPrefersStatusBarHidden:(Class)class {
	SEL origSel = @selector(prefersStatusBarHidden);
	SEL swizzledSel = @selector(swizzledPrefersStatusBarHidden);
	
	Method origMethod = class_getInstanceMethod(UIViewController.class, origSel);
	Method swizzledMethod = class_getInstanceMethod(UIViewController.class, swizzledSel);
	
	
	method_exchangeImplementations(
								   origMethod,
								   swizzledMethod
								   );
}

- (void)setStatusBarTransform:(CGAffineTransform)transform {
	NSAssert([self isKindOfClass:NSClassFromString(@"UIStatusBar")], @"Expected Status Bar");
	statusBar = self;
}

- (BOOL)swizzledPrefersStatusBarHidden {
	return ![[UIApplication sharedApplication] isStatusBarHidden];
}

@end


@interface ViewController () <StatusBarSwizzleDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageThing;
//@property (nonatomic, assign) BOOL statusBarHidden;
@end

@implementation ViewController
@synthesize statusBarHidden;

- (void)viewDidLoad {
	[super viewDidLoad];
	[UIView setSwizzleDelegate:self];
	NSLog(@"%@", [UIView statusBar]);
	[[self imageThing] setImage:[UIView statusBarImage]];
}

- (BOOL)prefersStatusBarHidden {
	return self.statusBarHidden;
}

@end
