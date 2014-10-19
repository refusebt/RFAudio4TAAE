//
//  AEOutputConvert.m
//  RFAudio For TAAE
//
//  Created by GZH on 14-4-3.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import "AEOutputConvert.h"
#import "AEOutputConvertWriter.h"
#import "RFAudioKit.h"

#define checkResult(result,operation) (_checkResult((result),(operation),strrchr(__FILE__, '/')+1,__LINE__))
static inline BOOL _checkResult(OSStatus result, const char *operation, const char* file, int line)
{
    if ( result != noErr )
	{
        NSLog(@"%s:%d: %s result %d %08X %4.4s\n", file, line, operation, (int)result, (int)result, (char*)&result);
        return NO;
    }
    return YES;
}

@interface AEOutputConvert ()
{
	AudioStreamBasicDescription _srcDesc;
	AudioStreamBasicDescription _destDesc;
	AudioFileTypeID _audioFileTypeID;
	AEOutputConvertWriter *_writer;
	int64_t _skip;
}

static void receiverCallback(id receiver, AEAudioController *audioController, void *source, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio);

@end

@implementation AEOutputConvert
@synthesize path = _path;
@synthesize convertType = _convertType;
@synthesize currentTime = _currentTime;
@synthesize isError = _isError;
@synthesize progressBlock = _progressBlock;
@synthesize finishBlock = _finishBlock;

- (id)initWithAudioController:(AEAudioController *)anAudioController path:(NSString *)aPath type:(AEOutputConvertType)aType
{
	if (!(self = [super init]))
		return nil;
	
	_path = aPath;
	_convertType = aType;
    _srcDesc = anAudioController.audioDescription;
	switch (aType)
	{
		case AEOutputConvertTypeALAW:
			{
				_audioFileTypeID = kAudioFileWAVEType;
								
				_destDesc.mFormatID = kAudioFormatALaw;
				_destDesc.mSampleRate = 8000.0f;
				_destDesc.mChannelsPerFrame = 1;
				UInt32 size = sizeof(AudioStreamBasicDescription);
				checkResult(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &size, &_destDesc), "AEOutputConvert.initWithAudioController");
			}
			break;
			case AEOutputConvertTypeAAC:
			{
				_audioFileTypeID = kAudioFileM4AType;
				
				memset(&_destDesc, 0, sizeof(_destDesc));
				_destDesc.mChannelsPerFrame = _srcDesc.mChannelsPerFrame;
				_destDesc.mSampleRate = _srcDesc.mSampleRate;
				_destDesc.mFormatID = kAudioFormatMPEG4AAC;
				UInt32 size = sizeof(_destDesc);
				checkResult(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &size, &_destDesc), "AEOutputConvert.initWithAudioController");
			}
			break;
		case AEOutputConvertTypeWAVE:
		default:
			{
				_audioFileTypeID = kAudioFileWAVEType;
				
				_destDesc = _srcDesc;
				_destDesc.mFormatFlags = (_audioFileTypeID == kAudioFileAIFFType ? kLinearPCMFormatFlagIsBigEndian : 0) | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
				_destDesc.mFormatID = kAudioFormatLinearPCM;
				_destDesc.mBitsPerChannel = 16;
				_destDesc.mBytesPerPacket =
				_destDesc.mBytesPerFrame = _destDesc.mChannelsPerFrame * (_destDesc.mBitsPerChannel/8);
				_destDesc.mFramesPerPacket = 1;
				UInt32 size = sizeof(AudioStreamBasicDescription);
				checkResult(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &size, &_destDesc), "AEOutputConvert.initWithAudioController");
			}
			break;
	}
	
	_writer = [[AEOutputConvertWriter alloc] initWithSrc:&_srcDesc dest:&_destDesc path:_path fileType:_audioFileTypeID];
	_skip = _srcDesc.mSampleRate / 10;
	
    return self;
}

- (void)dealloc
{
	if (_writer != nil)
	{
		[_writer finishWriting];
		_writer = nil;
	}
}

- (BOOL)prepareWithProgress:(void(^)(NSTimeInterval currentTime))aProgressBlock
					 finish:(void(^)(BOOL isError))aFinishBlock
{
	self.progressBlock = aProgressBlock;
	self.finishBlock = aFinishBlock;
	_currentTime = 0.0f;
	
	NSError *error = nil;
	if (![_writer beginWriting:&error])
	{
		_isError = YES;
		NSLog(@"%@", [error localizedDescription]);
		return NO;
	}
	
	return YES;
}

- (void)stopConvert
{
	[_writer finishWriting];
	
	if (!_isError)
	{
		if (_convertType == AEOutputConvertTypeALAW)
		{
			[RFAudioKit correctAlawHeader:[NSURL fileURLWithPath:_path]];
		}
	}
}

- (AEAudioControllerAudioCallback)receiverCallback
{
	return &receiverCallback;
}

+ (BOOL)AACEncodingAvailable
{
	return [AEAudioFileWriter AACEncodingAvailable];
}

static void receiverCallback(id receiver, AEAudioController *audioController, void *source, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio)
{
	AEOutputConvert *THIS = receiver;
	
    THIS->_currentTime += AEConvertFramesToSeconds(audioController, frames);
    
	BOOL bOk = checkResult([THIS->_writer writerSyncAudio:audio frames:frames], "AEOutputConvert.receiverCallback");
	if (!bOk)
	{
		// ERROR
		NSLog(@"AEOutputConvert convert Fail.");
		
		THIS->_isError = YES;
		[THIS stopConvert];
		[audioController removeOutputReceiver:THIS];

		dispatch_async(dispatch_get_main_queue(), ^{
			if ( THIS.finishBlock ) THIS.finishBlock(THIS->_isError);
		});
	}
	else
	{
		NSArray *channels = audioController.channels;
		if (channels.count > 0)
		{
			// 处理中
			THIS->_skip -= frames;
			if (THIS->_skip <= 0)
			{
				THIS->_skip = THIS->_srcDesc.mSampleRate / 10;
				dispatch_async(dispatch_get_main_queue(), ^{
					if ( THIS.progressBlock ) THIS.progressBlock(THIS->_currentTime);
				});
			}
		}
		else
		{
			// 结束
			THIS->_isError = NO;
			[THIS stopConvert];
			[audioController removeOutputReceiver:THIS];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if ( THIS.finishBlock ) THIS.finishBlock(THIS->_isError);
			});
		}
	}
}

@end
