//
//  RasMusicSelectViewController.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-19.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasMusicSelectViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface RasMusicSelectViewController ()
{

}
@property (nonatomic, strong) NSMutableArray *trackInfos;
@property (nonatomic, strong) RasTrackInfo *selectedTrackInfo;

- (void)btnFinish_Click:(id)sender;
- (void)btnSwitch_Click:(UISegmentedControl *)sender;

- (void)bindItunes;
- (void)bindDocument;

@end

@implementation RasMusicSelectViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	self.navigationItem.title = @"";
	self.navigationItem.leftBarButtonItem = [RasUIKit barBtnWithTitle:@"Close" target:self action:@selector(dismissMe)];
//	self.navigationItem.rightBarButtonItem = [RasUIKit barBtnWithTitle:@"Finish" target:self action:@selector(btnFinish_Click:)];
	
	UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:@[@"iTunes", @"Document"]];
	[sc setWidth:80 forSegmentAtIndex:0];
	[sc setWidth:80 forSegmentAtIndex:1];
	sc.tintColor = RGBA2COLOR(0, 118, 255, 1);
	sc.selectedSegmentIndex = 0;
	[sc addTarget:self action:@selector(btnSwitch_Click:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = sc;
	
	self.tblMusic.contentInset = UIEdgeInsetsMake(54, 0, 10, 0);
	
	[self bindItunes];
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

- (void)btnFinish_Click:(id)sender
{
	if (self.finish != nil)
	{
		self.finish(self.selectedTrackInfo);
	}
	[self dismissMe];
}

- (void)btnSwitch_Click:(UISegmentedControl *)sender
{
	if (sender.selectedSegmentIndex == 0)
	{
		[self bindItunes];
	}
	else
	{
		[self bindDocument];
	}
}

- (void)bindItunes
{
	NSMutableArray *array = [NSMutableArray array];
	MPMediaQuery *query = [[MPMediaQuery alloc] init];
	NSArray *itunesItems = [query items];
	if (itunesItems != nil)
	{
		for (NSInteger i = 0; i < itunesItems.count; i++)
		{
			MPMediaItem *item = itunesItems[i];
			NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
			
			RasTrackInfo *ti = [[RasTrackInfo alloc] init];
			ti.path = [url absoluteString];
			ti.location = RasTrackLocationItunes;
			ti.name = [item valueForProperty:MPMediaItemPropertyTitle];
			ti.date = [item valueForProperty:MPMediaItemPropertyLastPlayedDate];
			
			[array addObject:ti];
		}
	}
	self.trackInfos = array;
	[self.tblMusic reloadData];
}

- (void)bindDocument
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *dirPath = [RFStorageKit documentPathWithDirectory:nil file:nil];
	NSArray *urls = [fm contentsOfDirectoryAtURL:[NSURL fileURLWithPath:dirPath]
					  includingPropertiesForKeys:@[]
										 options:NSDirectoryEnumerationSkipsHiddenFiles
										   error:nil];
	NSMutableArray *array = [NSMutableArray array];
	for (NSInteger i = 0; i < urls.count; i++)
	{
		NSURL *url = urls[i];
		NSString *path = [url path];
		BOOL isDir = NO;
		if ([fm fileExistsAtPath:path isDirectory:&isDir])
		{
			if (!isDir)
			{
				NSString *ext = [path pathExtension];
				if ([ext isEqualToString:@"wav"]
					|| [ext isEqualToString:@"caf"]
					|| [ext isEqualToString:@"mp3"]
					|| [ext isEqualToString:@"mp4"]
					|| [ext isEqualToString:@"m4a"]
					|| [ext isEqualToString:@"m4r"])
				{
					RasTrackInfo *ti = [[RasTrackInfo alloc] init];
					ti.path = [path lastPathComponent];
					ti.location = RasTrackLocationDocument;
					ti.name = ti.path;
					ti.date = [RFStorageKit modificationDateWithPath:path];
					
					[array addObject:ti];
				}
			}
		}
	}
	self.trackInfos = array;
	[self.tblMusic reloadData];
}

#pragma mark - table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 1;
	}
	else
	{
		return self.trackInfos.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
	}
	
	if (indexPath.section == 0)
	{
		cell.textLabel.text = @"No background music";
	}
	else
	{
		RasTrackInfo *ti = self.trackInfos[indexPath.row];
		cell.textLabel.text = ti.name;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (indexPath.section == 0)
	{
		self.selectedTrackInfo = nil;
	}
	else
	{
		self.selectedTrackInfo = self.trackInfos[indexPath.row];
	}
	[self btnFinish_Click:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}

@end
