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
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

}

//- (void)checkNavBarPosition:(CADisplayLink *)displayLink {
//	static NSNumber *num = nil;//@(self.navigationController.navigationBar.frame.origin.y);
//	if (![num isEqualToNumber:@(self.tableView.frame.origin.y)]) {
//		NSLog(@"%@", @(self.tableView.frame.origin.y));
//		NSLog(@"%@", @(self.topLayoutGuide.length));
//		num = @(self.tableView.frame.origin.y);
//	}
//}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
//
//{
//	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	[[cell textLabel] setText:[[NSUUID UUID] UUIDString]];
	return cell;
}

@end
