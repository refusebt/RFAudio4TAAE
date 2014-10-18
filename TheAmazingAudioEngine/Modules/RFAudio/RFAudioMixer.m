//
//  AudioMixer.m
//  RFAudio For TAAE
//
//  Created by GZH on 12-2-3.
//  Copyright (c) 2012年 GZH. All rights reserved.
//

#import "RFAudioMixer.h"

#define VOLUME(v) \
	((v) < 0 ? 0.0f : (v))

#pragma mark - AudioMixTrackSectionSetting

typedef enum tagRFAudioMixTrackSectionSettingType
{
	RFAudioMixTrackSectionSettingTypeNONE = 0,
	RFAudioMixTrackSectionSettingTypeVolume = 1,
    RFAudioMixTrackSectionSettingTypeVolumeRamp = 2,
}
RFAudioMixTrackSectionSettingType;

@interface RFAudioMixTrackSectionSetting : NSObject
{
	
}
@property (nonatomic, assign) RFAudioMixTrackSectionSettingType type;
@property (nonatomic) CMTime sourceStart;		// 相对source
@property (nonatomic) CMTime sourceDuration;
@property (nonatomic) float volumeStart;
@property (nonatomic) float volumeEnd;

- (void)appendSettingToParameters:(AVMutableAudioMixInputParameters *)parameters forTrack:(RFAudioMixTrack *)track;

- (void)changeVolumeWithRatio:(float)ratio;
- (void)changeVolumeWithOffset:(float)offset;

+ (id)settingVolume:(float)v at:(CMTime)s;
+ (id)settingVolumeRampFromStartVolume:(float)sv toEndVolume:(float)ev at:(CMTime)s Duration:(CMTime)d;
@end

#pragma mark -AudioMixTrack

@interface RFAudioMixTrack()
{
	NSMutableArray *_sectionSettings;
}
- (AVMutableCompositionTrack *)compositionTrackWithComposition:(AVMutableComposition *)composition;
- (AVMutableAudioMixInputParameters *)audioMixInputParametersWithTrack:(AVMutableCompositionTrack *)compositionTrack;
@end

@interface RFAudioMixer()
- (AVPlayerItem*)originPlayerItem;
@end

#pragma mark -AudioMixTrackSectionSetting-

@implementation RFAudioMixTrackSectionSetting
@synthesize type = _type;
@synthesize sourceStart = _sourceStart;
@synthesize sourceDuration = _sourceDuration;
@synthesize volumeStart = _volumeStart;
@synthesize volumeEnd = _volumeEnd;

- (id)init
{
    self = [super init];
    if (self) 
    {
		_type = RFAudioMixTrackSectionSettingTypeNONE;
		_sourceStart = kCMTimeInvalid;
		_sourceDuration = kCMTimeInvalid;
		_volumeStart = 0.0f;
		_volumeEnd = 0.0f;
    }
    return self;
}

- (void)changeVolumeWithRatio:(float)ratio
{
	if (_type != RFAudioMixTrackSectionSettingTypeNONE)
	{
		_volumeStart *= ratio;
		_volumeEnd *= ratio;
	}
}

- (void)changeVolumeWithOffset:(float)offset
{
	if (_type != RFAudioMixTrackSectionSettingTypeNONE)
	{
		_volumeStart += offset;
		_volumeEnd += offset;
	}
}

- (void)appendSettingToParameters:(AVMutableAudioMixInputParameters *)parameters forTrack:(RFAudioMixTrack *)track;
{
	switch (_type)
	{
		case RFAudioMixTrackSectionSettingTypeVolume:
			{
				CMTime start = CMTimeAdd(track.targetStart, _sourceStart);
				[parameters setVolume:VOLUME(_volumeStart) atTime:start];
			}
			break;
		case RFAudioMixTrackSectionSettingTypeVolumeRamp:
			{
				CMTime start = CMTimeAdd(track.targetStart, _sourceStart);
				CMTimeRange range = CMTimeRangeMake(start, _sourceDuration);
				[parameters setVolumeRampFromStartVolume:VOLUME(_volumeStart) toEndVolume:VOLUME(_volumeEnd) timeRange:range];
			}
			break;
		default:
			break;
	}
}

+ (id)settingVolume:(float)v at:(CMTime)s
{
	RFAudioMixTrackSectionSetting *ret = nil;
	
	ret = [[RFAudioMixTrackSectionSetting alloc] init];
	ret.type = RFAudioMixTrackSectionSettingTypeVolume;
	ret.sourceStart = s;
	ret.volumeStart = v;
	
	return ret;
}

+ (id)settingVolumeRampFromStartVolume:(float)sv toEndVolume:(float)ev at:(CMTime)s Duration:(CMTime)d
{
	RFAudioMixTrackSectionSetting *ret = nil;
	
	ret = [[RFAudioMixTrackSectionSetting alloc] init];
	ret.type = RFAudioMixTrackSectionSettingTypeVolumeRamp;
	ret.volumeStart = sv;
	ret.volumeEnd = ev;
	ret.sourceStart = s;
	ret.sourceDuration = d;
	
	return ret;
}

@end

#pragma mark -AudioMixTrack-

@implementation RFAudioMixTrack
@synthesize name = _name;
@synthesize url = _url;
@synthesize asset = _asset;
@synthesize sourceStart = _sourceStart;
@synthesize sourceDuration = _sourceDuration;
@synthesize targetStart = _targetStart;
@synthesize targetDuration = _targetDuration;
@synthesize baseVolume = _baseVolume;

- (id)init
{
    self = [super init];
    if (self) 
    {
		_name = nil;
		_url = nil;
		_asset = nil;
		_sourceStart = kCMTimeInvalid;
		_sourceDuration = kCMTimeInvalid;
		_targetStart = kCMTimeInvalid;
		_targetDuration = kCMTimeInvalid;
		_baseVolume = 1.0f;
		_sectionSettings = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithURL:(NSURL *)aURL Name:(NSString *)anName
{
	self = [self init];
    if (self)
    {
		_name = [anName copy];
		_url = aURL;
		_asset = [AVURLAsset URLAssetWithURL:aURL options:nil];
		_sourceStart = kCMTimeZero;
		_sourceDuration = _asset.duration;
		_targetDuration = _sourceDuration;
    }
    return self;
}

- (void)setVolume:(float)v
{
	_baseVolume = v;
}

- (void)setVolumeByRatio:(float)ratio forWhole:(BOOL)isWhole
{
	_baseVolume *= ratio;
	
	if (isWhole) 
	{
		for (RFAudioMixTrackSectionSetting *setting in _sectionSettings)
		{
			[setting changeVolumeWithRatio:ratio];
		}
	}
}

- (void)setVolumeByOffset:(float)offset forWhole:(BOOL)isWhole
{
	_baseVolume += offset;
	
	if (isWhole)
	{
		for (RFAudioMixTrackSectionSetting *setting in _sectionSettings)
		{
			[setting changeVolumeWithOffset:offset];
		}
	}
}

- (void)setSourceStart:(CMTime)start Duration:(CMTime)duration
{
	_sourceStart = start;
	_sourceDuration = duration;
	_targetDuration = _sourceDuration;
}

- (void)setSourceStart:(CMTime)start End:(CMTime)end
{
	CMTime duration = CMTimeSubtract(end, start);
	[self setSourceStart:start Duration:duration];
}

- (void)setTargetPosition:(CMTime)position;
{
	_targetStart = position;
}

- (void)setTargetDuration:(CMTime)duration
{
    _targetDuration = duration;
}

- (BOOL)checkTimeRange:(CMTime)start Duration:(CMTime)duration
{
	CMTimeRange input = CMTimeRangeMake(start, duration);
	CMTimeRange source = CMTimeRangeMake(_sourceStart, _sourceDuration);
	if (CMTimeRangeContainsTimeRange(source, input)) 
		return YES;
	else
		return NO;
}

- (BOOL)checkDuration:(CMTime)duration;
{
	if (CMTIME_COMPARE_INLINE(duration, <=, _sourceDuration))
		return YES;
	else
		return NO;
}

- (BOOL)checkTime:(CMTime)position
{
	CMTimeRange source = CMTimeRangeMake(_sourceStart, _sourceDuration);
	if (CMTimeRangeContainsTime(source, position)) 
		return YES;
	else
		return NO;
}

- (void)addBeginVolumeRampWithDuration:(CMTime)duration
{
	RFAudioMixTrackSectionSetting* setting = [RFAudioMixTrackSectionSetting settingVolumeRampFromStartVolume:0.0f 
																							 toEndVolume:_baseVolume
																									  at:kCMTimeZero 
																								Duration:duration];
	[_sectionSettings addObject:setting];
}

- (void)addEndVolumeRampWithDuration:(CMTime)duration
{
	CMTime start = CMTimeAdd(kCMTimeZero, CMTimeSubtract(_sourceDuration, duration));
	RFAudioMixTrackSectionSetting *setting = [RFAudioMixTrackSectionSetting settingVolumeRampFromStartVolume:_baseVolume
																							 toEndVolume:0.0f
																									  at:start
																								Duration:duration];
	[_sectionSettings addObject:setting];
}

- (void)addBeginVolumeRampWithRatio:(float)ratio
{
	CMTime duration = CMTimeMultiplyByFloat64(_sourceDuration, ratio);
	[self addBeginVolumeRampWithDuration:duration];
}

- (void)addEndVolumeRampWithRatio:(float)ratio
{
	CMTime duration = CMTimeMultiplyByFloat64(_sourceDuration, ratio);
	[self addEndVolumeRampWithDuration:duration];
}

- (AVMutableCompositionTrack *)compositionTrackWithComposition:(AVMutableComposition *)composition
{
	AVMutableCompositionTrack *ret = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	
	// 对齐音轨
	NSMutableArray *segments = [[NSMutableArray alloc] init];
	{
		// 空白
		{
			CMTimeRange rangeTarget = CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(_targetStart, kCMTimeZero));
			AVCompositionTrackSegment *s = [AVCompositionTrackSegment compositionTrackSegmentWithTimeRange:rangeTarget];
			[segments addObject:s];
		}
		// 音源
		{
			NSArray* tracks = [_asset tracksWithMediaType:AVMediaTypeAudio];
			if (tracks.count > 0) 
			{
				AVAssetTrack* track = [tracks objectAtIndex:0];	// 取第一条音轨
				CMTimeRange rangeSrc = CMTimeRangeMake(_sourceStart, _sourceDuration);
				CMTimeRange rangeTarget = CMTimeRangeMake(_targetStart, _targetDuration);
				AVCompositionTrackSegment *s = [AVCompositionTrackSegment compositionTrackSegmentWithURL:_url
																								 trackID:track.trackID
																						 sourceTimeRange:rangeSrc
																						 targetTimeRange:rangeTarget];
				[segments addObject:s];
			}
		}
		ret.segments = segments;
	}
	
	return ret;
}

- (AVMutableAudioMixInputParameters *)audioMixInputParametersWithTrack:(AVMutableCompositionTrack *)compositionTrack
{
	AVMutableAudioMixInputParameters *ret = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionTrack];
	
	// 设定音轨音量
	[ret setVolume:_baseVolume atTime:_targetStart];
	
	// 其他设定
	for (RFAudioMixTrackSectionSetting *setting in _sectionSettings)
	{
		[setting appendSettingToParameters:ret forTrack:self];
	}
	
	return ret;
}

+ (id)trackWithURL:(NSURL *)aURL Name:(NSString *)anName
{
	RFAudioMixTrack *track = [[RFAudioMixTrack alloc] initWithURL:aURL Name:anName];
	return track;
}

@end

#pragma mark -AudioMixer-

@implementation RFAudioMixer
@synthesize tracks = _tracks;

- (id)init
{
    self = [super init];
    if (self) 
    {
		_tracks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addAudioMixTrack:(RFAudioMixTrack *)track
{
	[_tracks addObject:track];
}

- (AVPlayerItem *)originPlayerItem
{
	AVPlayerItem *ret = nil;
	
	@autoreleasepool
	{
		if (_tracks.count > 0)
		{
			AVMutableComposition *composition = [AVMutableComposition composition];
			AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
			NSMutableArray *audioMixInputParameters = [[NSMutableArray alloc] init];
			
			for (RFAudioMixTrack *track in _tracks)
			{
				AVMutableCompositionTrack *t = [track compositionTrackWithComposition:composition];
				AVMutableAudioMixInputParameters *p = [track audioMixInputParametersWithTrack:t];
				[audioMixInputParameters addObject:p];
			}
			audioMix.inputParameters = audioMixInputParameters;
			
			ret = [[AVPlayerItem alloc] initWithAsset:composition];
			ret.audioMix = audioMix;
		}
	}

	return ret;
}

- (AVPlayerItem *)avPlayerItem
{
	return [self originPlayerItem];
}

@end
