//
//  RecordViewController.h
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasBaseViewController.h"
#import "RasTrackEditorControl.h"

@interface RasRecordViewController : RasBaseViewController
{

}
@property (nonatomic, strong) IBOutlet UIButton *btnMusic;
@property (nonatomic, strong) IBOutlet UILabel *lbMusicTitle;
@property (nonatomic, strong) IBOutlet UIButton *btnReset;
@property (nonatomic, strong) IBOutlet UIButton *btnRecord;
@property (nonatomic, strong) IBOutlet UIButton *btnFinish;
@property (nonatomic, strong) IBOutlet UIButton *btnPlay;
@property (nonatomic, strong) IBOutlet UIButton *btnSave;
@property (nonatomic, strong) IBOutlet RasTrackEditorControl *trackEditorBg;
@property (nonatomic, strong) IBOutlet RasTrackEditorControl *trackEditorRecord;
@property (nonatomic, strong) IBOutlet UIButton *btnPlayBg;
@property (nonatomic, strong) IBOutlet UIButton *btnPlayRecord;

- (IBAction)btnMusic_Click:(id)sender;
- (IBAction)btnReset_Click:(id)sender;
- (IBAction)btnRecord_Click:(id)sender;
- (IBAction)btnFinish_Click:(id)sender;
- (IBAction)btnPlay_Click:(id)sender;
- (IBAction)btnSave_Click:(id)sender;

- (IBAction)btnPlayBg_Click:(id)sender;
- (IBAction)btnPlayRecord_Click:(id)sender;

@end
