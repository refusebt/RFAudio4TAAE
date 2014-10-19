//
//  RasUIKit.h
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RasUIKit : NSObject

+ (void)setRootCtrl:(UIViewController *)rootCtrl;
+ (UIViewController *)rootCtrl;

+ (RasBaseNavigationController *)navCtrlWithRootCtrl:(UIViewController *)rootCtrl;

+ (void)rootPresentViewController:(UIViewController *)viewController;
+ (void)rootPresentViewController:(UIViewController *)viewController statusBarStyle:(UIStatusBarStyle)statusBarStyle;

+ (UIBarButtonItem *)barBtnWithTitle:(NSString *)aTitle target:(id)aTarget action:(SEL)aSelector;

@end
