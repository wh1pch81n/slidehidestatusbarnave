//
//  NativeStatusBarCapture.m
//  StatusBarNavBar
//
//  Created by Derrick  Ho on 4/23/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

#import "NativeStatusBarCapture.h"


@implementation NativeStatusBarCapture

- (void)viewDidLoad {
	[super viewDidLoad];
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"hi" style:UIBarButtonItemStyleDone target:self action:@selector(toggleStatusBar)];
	self.navigationItem.rightBarButtonItem = item;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	CGFloat statusBarHeight = 20.0;
	UIScreen *screen = [UIScreen mainScreen];
	UIView *snapshotView = [screen snapshotViewAfterScreenUpdates:true];
	CGRect statusNavBarFrame = snapshotView.bounds;
	statusNavBarFrame.size.height = statusBarHeight + self.navigationController.navigationBar.frame.size.height;
	UIGraphicsBeginImageContextWithOptions(statusNavBarFrame.size, true, 0);
	[snapshotView drawViewHierarchyInRect:snapshotView.bounds afterScreenUpdates: true];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[[self imageStatus] setImage:image];	
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self toggleStatusBarNavBarVisibility];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	[[cell textLabel] setText:[[NSUUID UUID] UUIDString]];
	return cell;
}

#pragma mark UIScrollDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	self->didBeginDrag = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	static CGFloat lastPositionY = 0;

	if (didBeginDrag) {
		[self moveBoxByOffset:lastPositionY - scrollView.contentOffset.y];
	}
	lastPositionY = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	// after this, move it with animation
	[self moveBoxWithVelocity:velocity animatedWithCompletion:^(BOOL b) {
		[self setNeedsStatusBarAppearanceUpdate];
	}];
	didBeginDrag = NO;
}

//- (UIImage *)takeImageOfStatusBarNavBarRegion {
//	return self.imageStatus.image;
	
//	CGFloat statusBarHeight = 20.0;
//	UIScreen *screen = [UIScreen mainScreen];
//	UIView *snapshotView = [screen snapshotViewAfterScreenUpdates:true];
//	CGRect statusNavBarFrame = snapshotView.bounds;
//	statusNavBarFrame.size.height = statusBarHeight + self.navigationController.navigationBar.frame.size.height;
//	UIGraphicsBeginImageContextWithOptions(statusNavBarFrame.size, true, 0);
//	[snapshotView drawViewHierarchyInRect:snapshotView.bounds afterScreenUpdates: true];
//	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//	[[self imageStatus] setImage:image];
//	return image;
//}

//- (BOOL)prefersStatusBarHidden {
//	return [super prefersStatusBarHidden];
//}

- (void)toggleStatusBar {
	self.statusBarHidden = !self.statusBarHidden;
	[self setNeedsStatusBarAppearanceUpdate];
}

@end
