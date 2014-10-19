//
//  RecordViewController.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasRecordViewController.h"
#import "RasMusicSelectViewController.h"
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import <TheAmazingAudioEngine/AEWaveImageGenerator.h>
#import <TheAmazingAudioEngine/AEToneFilter.h>

@interface RasRecordViewController ()
{

}
@property (nonatomic, strong) AEAudioController *audioController;

- (void)resetAudioController;

@end

@implementation RasRecordViewController

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

- (IBAction)btnMusic_Click:(id)sender
{
	RasMusicSelectViewController *selectCtrl = [[RasMusicSelectViewController alloc] initWithNibName:@"RasMusicSelectViewController" bundle:nil];
	selectCtrl.finish = ^(RasTrackInfo *ti){
		[self resetAudioController];
		if (ti == nil)
		{
			return;
		}
		AVPlayerItem *playerItem = [ti avPlayerItem];
		if (playerItem == nil)
		{
			return;
		}

		self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
//		self.audioController = [[AEAudioController alloc] initGenericOutputWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]];
		_audioController.preferredBufferDuration = 0.005;
		_audioController.useMeasurementMode = YES;
		
		AEAvPlayerItemPlayer *player = [[AEAvPlayerItemPlayer alloc] initWithWithItem:playerItem audioController:self.audioController];
		[player prepareWithProgress:
		 ^(NSTimeInterval currentTime, NSTimeInterval duration){
			 NSLog(@"%f:%f", currentTime, duration);
		 }
							 finish:
		 ^(){
			 NSLog(@"%@ finish", player);
		 }];
		
		player.volume = 1.0;
		player.channelIsPlaying = YES;
		player.channelIsMuted = NO;
		
		AEChannelGroupRef group = [_audioController createChannelGroup];
		[_audioController addChannels:[NSArray arrayWithObjects:player, nil] toChannelGroup:group];
		
//		AEWaveImageGenerator *generator = [[AEWaveImageGenerator alloc] initWithAudioController:self.audioController width:1920 height:90 duration:player.duration color:[UIColor redColor]];
//		generator.finish = ^(UIImage *image){
//			self.imgViewBgWave.image = image;
//		};
//		[_audioController addOutputReceiver:generator];
		
		AEToneFilter *up = [[AEToneFilter alloc] init];
		[_audioController addFilter:up];
		
		NSError *error = nil;
		[self.audioController start:&error];
		if (error != nil)
		{
			NSLog(@"%@", error);
		}
	};
	[self presentViewController:[RasUIKit navCtrlWithRootCtrl:selectCtrl] animated:YES];
}

- (IBAction)btnReset_Click:(id)sender
{
	
}

- (IBAction)btnRecord_Click:(id)sender
{
	
}

- (IBAction)btnFinish_Click:(id)sender
{
	
}

- (IBAction)btnPlay_Click:(id)sender
{
	
}

- (IBAction)btnSave_Click:(id)sender
{
	
}

- (void)resetAudioController
{
	if (self.audioController != nil)
	{
		[self.audioController stop];
		self.audioController = nil;
	}
}

@end
