//
//  RasMainViewController.h
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RFBaseTabBarController.h"
#import "RasRecordViewController.h"
#import "RasMixerViewController.h"

@interface RasMainViewController : RFBaseTabBarController
<
	UITabBarControllerDelegate
>
{
	
}
@property (nonatomic, strong) RasBaseNavigationController *recordNavCtrl;
@property (nonatomic, strong) RasBaseNavigationController *mixerNavCtrl;
@property (nonatomic, strong) RasRecordViewController *recordCtrl;
@property (nonatomic, strong) RasMixerViewController *mixerCtrl;

@end
