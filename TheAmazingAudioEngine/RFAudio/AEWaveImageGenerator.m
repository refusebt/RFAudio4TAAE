//
//  AEWaveImageGenerator.m
//  TheAmazingAudioEngine
//
//  Created by gouzhehua on 14-10-19.
//  Copyright (c) 2014年 A Tasty Pixel. All rights reserved.
//

#import "AEWaveImageGenerator.h"
#import <Accelerate/Accelerate.h>

@interface AEWaveImageGenerator ()
{
	AEAudioController *_audioController;
	NSInteger _groupSamples;
	AudioStreamBasicDescription _srcDesc;
}
@property (nonatomic, assign) NSInteger waveImageWidth;
@property (nonatomic, assign) NSInteger waveImageHeight;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) UIColor *color;


@end

static void receiverCallback(id receiver, AEAudioController *audioController, void *source, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio);

@implementation AEWaveImageGenerator
@synthesize waveImageWidth = _waveImageWidth;
@synthesize waveImageHeight = _waveImageHeight;
@synthesize duration = _duration;
@synthesize color = _color;
@synthesize waveImage = _waveImage;
@synthesize finish = _finish;

- (id)initWithAudioController:(AEAudioController *)audioController
						width:(NSInteger)width
					   height:(NSInteger)height
					 duration:(NSTimeInterval)duration
						color:(UIColor *)color
{
	if (!(self = [super init]))
		return nil;
	
	_audioController = audioController;
	_waveImageWidth = width;
	_waveImageHeight = height;
	_duration = duration;
	_color = color;
	_srcDesc = audioController.audioDescription;
	_groupSamples = (duration * _srcDesc.mSampleRate / _waveImageWidth);
	
	return self;
}

- (AEAudioControllerAudioCallback)receiverCallback
{
	return &receiverCallback;
}

static void receiverCallback(id receiver, AEAudioController *audioController, void *source, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio)
{
	AEWaveImageGenerator *THIS = receiver;
	
	NSArray *channels = audioController.channels;
	if (channels.count > 0)
	{
		// 处理中
		const int size = 512;
		static vDSP_Length n = 0;
		static FFTSetup setup = NULL;
		
		if (setup == NULL)
		{
			n = log2f( ( float) size );
			setup = vDSP_create_fftsetup(n, FFT_RADIX2);
		}
		
		const int channel = 0;
		int16_t *buffer = (int16_t *)audio->mBuffers[channel].mData;
		float fbuf[512];
		
		memset(fbuf, 0, sizeof(fbuf));
		vDSP_vflt16(buffer, 1, fbuf, 1, 512);
		
		
		
	}
	else
	{
		// 结束
//		THIS->_isError = NO;
//		[THIS stopConvert];
		[audioController removeOutputReceiver:THIS];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if ( THIS.finish ) THIS.finish(nil);
		});
	}
	
//	THIS->_currentTime += AEConvertFramesToSeconds(audioController, frames);
//	
//	BOOL bOk = checkResult([THIS->_writer writerSyncAudio:audio frames:frames], "AEOutputConvert.receiverCallback");
//	if (!bOk)
//	{
//		// ERROR
//		NSLog(@"AEOutputConvert convert Fail.");
//		
//		THIS->_isError = YES;
//		[THIS stopConvert];
//		[audioController removeOutputReceiver:THIS];
//		
//		dispatch_async(dispatch_get_main_queue(), ^{
//			if ( THIS.finishBlock ) THIS.finishBlock(THIS->_isError);
//		});
//	}
//	else
//	{
//		NSArray *channels = audioController.channels;
//		if (channels.count > 0)
//		{
//			// 处理中
//			THIS->_skip -= frames;
//			if (THIS->_skip <= 0)
//			{
//				THIS->_skip = THIS->_srcDesc.mSampleRate / 10;
//				dispatch_async(dispatch_get_main_queue(), ^{
//					if ( THIS.progressBlock ) THIS.progressBlock(THIS->_currentTime);
//				});
//			}
//		}
//		else
//		{
//			// 结束
//			THIS->_isError = NO;
//			[THIS stopConvert];
//			[audioController removeOutputReceiver:THIS];
//			
//			dispatch_async(dispatch_get_main_queue(), ^{
//				if ( THIS.finishBlock ) THIS.finishBlock(THIS->_isError);
//			});
//		}
//	}
}

@end
