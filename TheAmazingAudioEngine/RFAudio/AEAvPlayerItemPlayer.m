//
//  AEAvPlayerItemPlayer.m
//  RFAudio For TAAE
//
//  Created by GZH on 14-3-31.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import "AEAvPlayerItemPlayer.h"
#import <libkern/OSAtomic.h>

@interface AEAvPlayerItemPlayer ()
{
	AEAssetReader					*_assetReader;
    AudioStreamBasicDescription		_audioDescription;
	int64_t							_full;
    volatile int64_t				_used;
	int64_t							_skip;
}

static OSStatus renderCallback(AEAvPlayerItemPlayer *THIS, AEAudioController *audioController, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio);

@end

@implementation AEAvPlayerItemPlayer
@synthesize avPlayerItem = _avPlayerItem;
@synthesize duration = _duration;
@synthesize currentTime = _currentTime;
@synthesize volume = _volume;
@synthesize pan = _pan;
@synthesize channelIsPlaying = _channelIsPlaying;
@synthesize channelIsMuted = _channelIsMuted;
@synthesize progressBlock = _progressBlock;
@synthesize finishBlock = _finishBlock;

- (id)initWithWithItem:(AVPlayerItem *)anItem audioController:(AEAudioController *)anAudioController
{
    if (!(self = [super init]))
		return nil;
	
	_avPlayerItem = anItem;
	_volume = 1.0;
    _channelIsPlaying = YES;
    _audioDescription = anAudioController.audioDescription;
	_assetReader = [[AEAssetReader alloc] initWithAssert:anItem.asset audioMix:anItem.audioMix basicDesc:&_audioDescription];
	_skip = _audioDescription.mSampleRate / 10;
	
    return self;
}

- (BOOL)prepareWithProgress:(void(^)(NSTimeInterval currentTime, NSTimeInterval duration))aProgressBlock
					 finish:(void(^)())aFinishBlock
{
	self.progressBlock = aProgressBlock;
	self.finishBlock = aFinishBlock;
	
	BOOL bRet = [_assetReader startWorkWithFramePos:0];
	if (bRet)
	{
		_full = _assetReader.fullFrames;
		_used = 0;
	}
	return bRet;
}

-(void)dealloc
{
	if (_assetReader != nil)
	{
		[_assetReader stopWork];
		_assetReader = nil;
	}
}

- (AEAudioControllerRenderCallback)renderCallback
{
    return &renderCallback;
}

-(NSTimeInterval)duration
{
    return (double)_full / (double)_audioDescription.mSampleRate;
}

-(NSTimeInterval)currentTime
{
    return ((double)_used / (double)_full) * [self duration];
}

-(void)setCurrentTime:(NSTimeInterval)time
{
    _used = (int64_t)((time / [self duration]) * _full) % _full;
}

static OSStatus renderCallback(AEAvPlayerItemPlayer *THIS, AEAudioController *audioController, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio)
{
    int64_t usedSize = THIS->_used;
    int64_t originalUsedSize = usedSize;
    
    if (!THIS->_channelIsPlaying)
		return noErr;
    
	UInt32 written = [THIS->_assetReader fillAudioBufferList:audio frames:frames];
	usedSize += written;
	
	if (usedSize >= THIS->_full)
	{
		// Notify main thread that playback has finished
		dispatch_async(dispatch_get_main_queue(), ^{
			if ( THIS.finishBlock ) THIS.finishBlock();
			THIS->_used = 0;
		});
		
		[audioController removeChannels:[NSArray arrayWithObject:THIS]];
        THIS->_channelIsPlaying = NO;
		
        return noErr;
	}
	else
	{
		THIS->_skip -= frames;
		if (THIS->_skip <= 0)
		{
			THIS->_skip = THIS->_audioDescription.mSampleRate / 20;
			dispatch_async(dispatch_get_main_queue(), ^{
				if ( THIS.progressBlock ) THIS.progressBlock([THIS currentTime], [THIS duration]);
			});
		}
	}
	
    OSAtomicCompareAndSwap64(originalUsedSize, usedSize, &THIS->_used);
    
    return noErr;
}

@end
