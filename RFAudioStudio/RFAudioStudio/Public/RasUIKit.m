//
//  RasUIKit.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasUIKit.h"

static UIViewController *s_rootCtrl = nil;

@implementation RasUIKit

+ (void)setRootCtrl:(UIViewController *)rootCtrl
{
	s_rootCtrl = rootCtrl;
}

+ (UIViewController *)rootCtrl
{
	return s_rootCtrl;
}

+ (RasBaseNavigationController *)navCtrlWithRootCtrl:(UIViewController *)rootCtrl
{
	RasBaseNavigationController *navigationController = [[RasBaseNavigationController alloc] initWithRootViewController:rootCtrl];
	
	
	return navigationController;
}

+ (void)rootPresentViewController:(UIViewController *)viewController
{
	[[RasUIKit rootCtrl] presentViewController:viewController animated:YES completion:^(){}];
}

+ (void)rootPresentViewController:(UIViewController *)viewController statusBarStyle:(UIStatusBarStyle)statusBarStyle
{
	[UIApplication sharedApplication].statusBarHidden = NO;
	[UIApplication sharedApplication].statusBarStyle = statusBarStyle;
	[[RasUIKit rootCtrl] presentViewController:viewController animated:YES completion:^(){}];
}

+ (UIBarButtonItem *)barBtnWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)aSelector
{
	UIButton *button =[UIButton buttonWithType:UIButtonTypeSystem];
	[button addTarget:aTarget action:aSelector forControlEvents:UIControlEventTouchUpInside];
	button.bounds = CGRectMake(0, 0, 50, 30);
	button.backgroundColor = [UIColor clearColor];
	[button setTitleForAllState:aTitle];
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	return barButton;
}

@end
