//
//  RasMainViewController.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasMainViewController.h"

@interface RasMainViewController ()

@end

@implementation RasMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.delegate = self;
	
	self.recordCtrl = [[RasRecordViewController alloc] initWithNibName:@"RasRecordViewController" bundle:nil];
	self.mixerCtrl = [[RasMixerViewController alloc] initWithNibName:@"RasMixerViewController" bundle:nil];
	
	self.recordNavCtrl = [RasUIKit navCtrlWithRootCtrl:self.recordCtrl];
	self.mixerNavCtrl = [RasUIKit navCtrlWithRootCtrl:self.mixerCtrl];
	
	{
		UIViewController *ctrl = self.recordCtrl;
		ctrl.title = @"Record";
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:ctrl.title
														   image:nil
												   selectedImage:nil];
		ctrl.tabBarItem = item;
	}
	{
		UIViewController *ctrl = self.mixerCtrl;
		ctrl.title = @"Mixer";
		UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:ctrl.title
														   image:nil
												   selectedImage:nil];
		ctrl.tabBarItem = item;
	}
	
	self.viewControllers = @[self.recordNavCtrl, self.mixerNavCtrl];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	
}

@end
