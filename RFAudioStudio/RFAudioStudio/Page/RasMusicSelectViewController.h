//
//  RasMusicSelectViewController.h
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-19.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasBaseViewController.h"
#import "RasTrackInfo.h"

@interface RasMusicSelectViewController : RasBaseViewController
<
	UITableViewDataSource
	, UITableViewDelegate
>
{

}
@property (nonatomic, strong) IBOutlet UITableView *tblMusic;
@property (nonatomic, copy) void(^finish)(RasTrackInfo *ti);

@end
