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
	NSInteger _delta;
	NSInteger _currentIdx;
	AudioStreamBasicDescription _srcDesc;
	NSMutableArray *_samples;
	int16_t _maxAbsSample;
}
@property (nonatomic, assign) NSInteger waveImageWidth;
@property (nonatomic, assign) NSInteger waveImageHeight;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) UIColor *color;

- (void)startProcess;
- (void)finishProcess;
- (void)drawWaveImage;

@end

static void receiverCallback(id receiver, AEAudioController *audioController, void *source, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio);
static int16_t valueRegular(int16_t value);

@implementation AEWaveImageGenerator
@synthesize waveImageWidth = _waveImageWidth;
@synthesize waveImageHeight = _waveImageHeight;
@synthesize duration = _duration;
@synthesize color = _color;
@synthesize waveImage = _waveImage;
@synthesize isHeightMax = _isHeightMax;
@synthesize startBlock = _startBlock;
@synthesize finishBlock = _finishBlock;

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
	_delta = (duration * _srcDesc.mSampleRate / _waveImageWidth);
	_currentIdx = 0;
	_samples = [NSMutableArray array];
	_maxAbsSample = 0;
	_isHeightMax = NO;
	
	return self;
}

+ (AEWaveImageGenerator *)waveImageWithAssert:(AVURLAsset *)assert
										 size:(CGSize)size
										color:(UIColor *)color
								  isHeightMax:(BOOL)isHeightMax
										start:(AEWaveImageGeneratorBlock)startBlock
									   finish:(AEWaveImageGeneratorBlock)finishBlock
{
	if (assert == nil)
	{
		return nil;
	}
	
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:assert];
	AEAudioController *audioController = [[AEAudioController alloc] initGenericOutputWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]];
	audioController.preferredBufferDuration = 0.005;
	audioController.useMeasurementMode = YES;
	
	AEAvPlayerItemPlayer *player = [[AEAvPlayerItemPlayer alloc] initWithWithItem:playerItem audioController:audioController];
	player.volume = 1.0;
	player.channelIsPlaying = YES;
	player.channelIsMuted = NO;
	[player prepareWithProgress:nil finish:nil];
	
	AEChannelGroupRef group = [audioController createChannelGroup];
	[audioController addChannels:[NSArray arrayWithObjects:player, nil] toChannelGroup:group];
	
	AEWaveImageGenerator *generator = [[AEWaveImageGenerator alloc] initWithAudioController:audioController width:size.width height:size.height duration:player.duration color:color];
	generator.isHeightMax = isHeightMax;
	generator.startBlock = startBlock;
	generator.finishBlock = finishBlock;
	[audioController addOutputReceiver:generator];
	
	NSError *error = nil;
	[audioController start:&error];
	if (error != nil)
	{
		NSLog(@"%@", error);
		return nil;
	}
	
	[generator startProcess];
	
	return generator;
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
		NSInteger start = THIS->_currentIdx;
		NSInteger end = start + frames;
		NSInteger delta = THIS->_delta;
		NSInteger sampleCount = end / delta;
		if (sampleCount > 0)
		{
			int16_t *leftBuf = NULL;
			int16_t *rightBuf = NULL;
			if (audio->mNumberBuffers > 0)
				leftBuf = (int16_t *)audio->mBuffers[0].mData;
			if (audio->mNumberBuffers > 1)
				rightBuf = (int16_t *)audio->mBuffers[1].mData;
			
			NSInteger idx = delta - start;
			while (idx < frames)
			{
				int16_t v = 0;
				
				if (leftBuf != NULL)
				{
					v = leftBuf[idx];
				}
				
				// 如果有右声道正交混入左声道
				if (rightBuf != NULL)
				{
					int16_t r = rightBuf[idx];
					if ((v < 0) && (r < 0))
					{
						v = v + r - (v * r / -(pow(2, 16-1)-1));
					}
					else
					{
						v = v + r - (v * r / (pow(2, 16-1)-1));
					}
					v = valueRegular(v);
				}
				
				[THIS->_samples addObject:[NSNumber numberWithInteger:v]];
				THIS->_maxAbsSample = MAX(THIS->_maxAbsSample, abs(v));
				
				idx += delta;
			}
		}
		THIS->_currentIdx = end % delta;
	}
	else
	{
		// 结束
		[THIS finishProcess];
	}
}

static int16_t valueRegular(int16_t value)
{
	int16_t newValue = value;

	if (newValue < -32767)
	{
		return -32767;
	}
	
	if (newValue > 32767)
	{
		return 32767;
	}
	
	return newValue;
}

- (void)startProcess
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.startBlock != nil)
			self.startBlock(self);
	});
}

- (void)finishProcess
{
	// 结束
	[_audioController removeOutputReceiver:self];
	[_audioController stop];
	_audioController = nil;
	
	// 绘制
	[self drawWaveImage];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.finishBlock != nil)
			self.finishBlock(self);
	});
}

- (void)drawWaveImage
{
	if (_samples.count == 0)
	{
		return;
	}
	
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	NSInteger bitmapByteCount = 0;
	NSInteger bitmapBytesPerRow = 0;
	size_t pixelsWide = _waveImageWidth;
	size_t pixelsHigh = _waveImageHeight;
	
	bitmapBytesPerRow = (pixelsWide * 4);
	bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (NULL,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 1);
	if (context == NULL)
	{
		CGColorSpaceRelease(colorSpace);
		fprintf (stderr, "Context not created!");
		return;
	}
	
	CGContextSetLineWidth(context, 1);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetStrokeColorWithColor(context, _color.CGColor);
	
	CGContextBeginPath(context);
	
	CGFloat hh = _waveImageHeight;
	
	CGFloat prex = 0;
	CGFloat prey = 0;
	CGFloat x = 0;
	CGFloat y = 0;
	NSInteger max = _isHeightMax ? _maxAbsSample : 32768.0;
	CGFloat k = hh/2/max;
	
	for (NSInteger i = 0; i < _waveImageWidth; i++)
	{
		x = i;
		
		NSInteger v = 0;
		if (i < _samples.count)
		{
			v = [_samples[i] integerValue];
		}
		y = hh - (NSInteger)(v*k + hh/2);
		
		// 连线
		CGContextMoveToPoint(context, prex, prey);
		CGContextAddLineToPoint(context, x, y);
		
		prex = x;
		prey = y;
	}
	
	CGContextDrawPath(context, kCGPathStroke);
	
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
	self.waveImage = [UIImage imageWithCGImage:cgimg];
	CGImageRelease(cgimg);
	CGContextRelease(context);
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease(colorSpace);
}

@end
