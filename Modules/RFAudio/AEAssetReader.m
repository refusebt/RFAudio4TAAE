//
//  AEAssetReader.m
//  RFAudio For TAAE
//
//  Created by GZH on 14-4-1.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import "AEAssetReader.h"

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

@interface AEAssetReader ()
{
	AVAssetReader *_assetReader;
	AVAssetReaderOutput *_assetReaderOutput;
	CMSampleBufferRef _sampleBufferRef;
	CMBlockBufferRef _blockBufferRef;
	AudioBufferList *_pAudioBufferList;
	int64_t _audioBufferListPos;
	int64_t _audioBufferListLen;
}

- (BOOL)resetAssetReaderWithStart:(CMTime)start;
- (void)resetBuffer;
- (BOOL)nextAudioBufferList;

@end

@implementation AEAssetReader
@synthesize asset = _asset;
@synthesize audioMix = _audioMix;
@synthesize fileSize = _fileSize;
@synthesize fullFrames = _fullFrames;
@synthesize byteRate = _byteRate;
@synthesize formatExtension = _formatExtension;
@synthesize requireAudioDesc = _requireAudioDesc;
@synthesize outAudioDesc = _outAudioDesc;

- (id)initWithAssert:(AVAsset *)anAsset audioMix:(AVAudioMix *)anAudioMix basicDesc:(AudioStreamBasicDescription *)aDesc
{
	self = [super init];
    if (self)
    {
		_asset = anAsset;
		_audioMix = anAudioMix;
		if (aDesc != NULL)
		{
			_requireAudioDesc = *aDesc;
		}
		_fileSize = 0;
		_formatExtension = @"";
		_assetReader = nil;
		_assetReaderOutput = nil;
		_byteRate = 0;
		
		_sampleBufferRef = NULL;
		_blockBufferRef = NULL;
		_audioBufferListPos = 0;
		_audioBufferListLen = 0;
    }
    return self;
}

- (void)dealloc
{
	[self resetBuffer];
}

- (BOOL)isInitialized
{
	return (_fullFrames > 0);
}

- (BOOL)startWorkWithFramePos:(int64_t)framePos
{
	// 停止当前Assert操作
	[self stopWork];
	
	CMTime start = kCMTimeZero;
	
	// 计算起始时间
	if ([self isInitialized] && (_asset != nil))
	{
		start = CMTimeMultiplyByFloat64(_asset.duration, (((Float64)framePos) / ((Float64)_fullFrames)));
	}
	
	// 重置reader
	return [self resetAssetReaderWithStart:start];
}

- (void)stopWork
{
	if (_assetReader != nil)
	{
		[_assetReader cancelReading];
	}
}

#pragma mark inner

- (UInt32)fillAudioBufferList:(AudioBufferList *)pOutAudioBufferList frames:(UInt32)frames
{
	int64_t need = frames;
	UInt32 written = 0;
	UInt32 bytesPerFrame = _outAudioDesc.mBytesPerFrame;
	
	Byte *toAudio[pOutAudioBufferList->mNumberBuffers];
    for (NSInteger i = 0; i < pOutAudioBufferList->mNumberBuffers; i++)
	{
        toAudio[i] = pOutAudioBufferList->mBuffers[i].mData;
    }
	
	do
	{
		if (_blockBufferRef != NULL)
		{
			int64_t write = MIN(need, (_audioBufferListLen - _audioBufferListPos));
			
			for (NSInteger i = 0; i < _pAudioBufferList->mNumberBuffers; i++)
			{
				Byte *fromAudio = _pAudioBufferList->mBuffers[i].mData;
				memcpy(toAudio[i], fromAudio + _audioBufferListPos * bytesPerFrame, (size_t)(write * bytesPerFrame));
				toAudio[i] += write * bytesPerFrame;
			}
			
			_audioBufferListPos += write;
			need -= write;
			written += write;
		}
		
		if (need > 0 && _audioBufferListPos >= _audioBufferListLen)
		{
			if (![self nextAudioBufferList])
			{
				[self startWorkWithFramePos:0];
				break;
			}
		}
	}
	while (need > 0);
	
	return written;
}

- (BOOL)resetAssetReaderWithStart:(CMTime)start
{
	// 清空
	if (_assetReader != nil)
		[_assetReader cancelReading];
	
	_assetReaderOutput = nil;
	_assetReader = nil;
	
	[self resetBuffer];
	
	// 创建
	if ((_asset != nil) && (_asset.isReadable))
	{
		NSDictionary *settings = nil;
		if (_requireAudioDesc.mSampleRate > 0)
		{
			settings = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSNumber numberWithInteger:kAudioFormatLinearPCM], AVFormatIDKey,
						[NSNumber numberWithFloat:_requireAudioDesc.mSampleRate], AVSampleRateKey,
						[NSNumber numberWithInteger:_requireAudioDesc.mBitsPerChannel], AVLinearPCMBitDepthKey,
						[NSNumber numberWithInteger:_requireAudioDesc.mChannelsPerFrame], AVNumberOfChannelsKey,
						[NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
						[NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
						[NSNumber numberWithBool:YES], AVLinearPCMIsNonInterleaved,
						nil];
		}
		AVAssetReaderAudioMixOutput *output = [[AVAssetReaderAudioMixOutput alloc] initWithAudioTracks:_asset.tracks audioSettings:settings];
		output.audioMix = _audioMix;
		
		_assetReader = [AVAssetReader assetReaderWithAsset:_asset error:nil];
		_assetReaderOutput = output;
		
		[_assetReader addOutput:_assetReaderOutput];
		[_assetReader setTimeRange:CMTimeRangeMake(start, kCMTimePositiveInfinity)];
		if ([_assetReader startReading])
		{
			return [self nextAudioBufferList];
		}
	}
	
	return NO;
}

- (void)resetBuffer
{
	if (_blockBufferRef != NULL)
	{
		CFRelease(_blockBufferRef);
		_blockBufferRef = NULL;
	}
	if (_sampleBufferRef != NULL)
	{
		checkResult(CMSampleBufferInvalidate(_sampleBufferRef), "AEAssetReader.resetBuffer");
		CFRelease(_sampleBufferRef);
		_sampleBufferRef = NULL;
	}
	if (_pAudioBufferList != NULL)
	{
		free(_pAudioBufferList);
		_pAudioBufferList = NULL;
	}
	
	_audioBufferListPos = 0;
	_audioBufferListLen = 0;
}

- (BOOL)nextAudioBufferList
{
	[self resetBuffer];
	
	if ((_asset != nil) && (_assetReader != nil) && (_assetReaderOutput != nil) &&
		(_assetReader.status == AVAssetReaderStatusReading))
	{
		_sampleBufferRef = [_assetReaderOutput copyNextSampleBuffer];
		_audioBufferListLen = CMSampleBufferGetNumSamples(_sampleBufferRef);
		if (_sampleBufferRef != NULL || _audioBufferListLen > 0)
		{
			size_t bufferListSizeNeededOut;
			CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(_sampleBufferRef, &bufferListSizeNeededOut, NULL, 0, NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, NULL);
			_pAudioBufferList = calloc(1, bufferListSizeNeededOut);
			BOOL bOk = checkResult(CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(_sampleBufferRef, &bufferListSizeNeededOut, _pAudioBufferList, bufferListSizeNeededOut, NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &_blockBufferRef), "AEAssetReader.nextAudioBufferList");
			if (bOk)
			{
				// 未初始化
				if (![self isInitialized])
				{
					// 通过比特率换算长度
					size_t blockLength = CMBlockBufferGetDataLength(_blockBufferRef);
					CMTime packetDuration = CMSampleBufferGetOutputDuration(_sampleBufferRef);
					_byteRate = ((Float64)blockLength) / CMTimeGetSeconds(packetDuration);
					_fileSize = _byteRate * CMTimeGetSeconds(_asset.duration);
					_fullFrames = (((Float64)_audioBufferListLen) / CMTimeGetSeconds(packetDuration)) * CMTimeGetSeconds(_asset.duration);
					
					// 得到格式信息
					CMFormatDescriptionRef fmtDescriptionRef = CMSampleBufferGetFormatDescription(_sampleBufferRef);
					if (fmtDescriptionRef != NULL)
					{
						AudioStreamBasicDescription *sampleFormatRef = (AudioStreamBasicDescription *)CMAudioFormatDescriptionGetStreamBasicDescription(fmtDescriptionRef);
						if (sampleFormatRef != NULL)
						{
							//ADTS
							switch (sampleFormatRef->mFormatID)
							{
								case kAudioFormatAC3:
								case kAudioFormat60958AC3:
									_formatExtension = @"ac3";
									break;
								default:
									_formatExtension = @"";	// 一般不需要显式设定，仅AC3和ADTS需要，参见AudioFileStreamOpen
									break;
							}
							_outAudioDesc = *sampleFormatRef;
						}
					}
				}
				
				return YES;
			}
		}
	}
	
	return NO;
}

@end
