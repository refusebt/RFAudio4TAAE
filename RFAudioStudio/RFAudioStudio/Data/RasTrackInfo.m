//
//  RasTrackInfo.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-19.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasTrackInfo.h"

@implementation RasTrackInfo

- (NSURL *)assertUrl
{
	NSURL *url = nil;
	switch (self.location)
	{
		case RasTrackLocationDocument:
		{
			NSString *path = [RFStorageKit documentPathWithDirectory:nil file:self.path];
			url = [NSURL fileURLWithPath:path];
		}
			break;
		case RasTrackLocationTmp:
		{
			NSString *path = [RFStorageKit tmpPathWithDirectory:nil file:self.path];
			url = [NSURL fileURLWithPath:path];
		}
			break;
		case RasTrackLocationCache:
		{
			NSString *path = [RFStorageKit cachePathWithDirectory:nil file:self.path];
			url = [NSURL fileURLWithPath:path];
		}
			break;
		case RasTrackLocationItunes:
			url = [NSURL URLWithString:self.path];
			break;
		case RasTrackLocationNet:
			url = [NSURL URLWithString:self.path];
			break;
		default:
			break;
	}
	return url;
}

- (AVURLAsset *)assert
{
	AVURLAsset *assert = nil;
	NSURL *url = [self assertUrl];
	if (url != nil)
	{
		assert = [AVURLAsset assetWithURL:url];
	}
	return assert;
}

- (AVPlayerItem *)avPlayerItem
{
	AVURLAsset *assert = [self assert];
	if (assert != nil)
	{
		return [[AVPlayerItem alloc] initWithAsset:assert];
	}
	return nil;
}

@end
