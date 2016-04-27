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
	self.navigationController.hidesBarsOnTap = YES;
	self.navigationController.hidesBarsOnSwipe = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController.navigationBar addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController.navigationBar removeObserver:self forKeyPath:@"hidden"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if ([object isKindOfClass:[UINavigationBar class]]) {
		UINavigationBar *bar = object;
		if ([keyPath isEqualToString:@"hidden"]) {
			[[UIApplication sharedApplication] setStatusBarHidden:self.navigationController.navigationBar.hidden];
			
		}
	}
}

//- (void)viewDidLayoutSubviews {
//	[super viewDidLayoutSubviews];
//	NSLog(@"viewDidlayout subviews");
//}
//
//- (void)layoutSublayersOfLayer:(CALayer *)layer {
//	[super layoutSublayersOfLayer:layer];
//	NSLog(@"Layout");
//}
//
//- (id<UILayoutSupport>)topLayoutGuide {
//	id val = [super topLayoutGuide];
//	NSLog(@"top layout guide");
//	return val;
//}

@end
