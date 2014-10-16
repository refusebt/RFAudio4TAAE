//
//  AudioMixer.h
//  RFAudio For TAAE
//
//  Created by GZH on 12-2-3.
//  Copyright (c) 2012年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class RFAudioMixTrackSectionSetting;
@class RFAudioMixTrack;
@class RFAudioMixer;

typedef void(^RFAudioMixerExportHandler)(AVAssetExportSession *);

#pragma mark - RFAudioMixTrack

@interface RFAudioMixTrack : NSObject
{
	
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) AVAsset *asset;
@property (nonatomic, readonly) CMTime sourceStart;
@property (nonatomic, readonly) CMTime sourceDuration;
@property (nonatomic, readonly) CMTime targetStart;
@property (nonatomic, readonly) CMTime targetDuration;
@property (nonatomic, readonly) float baseVolume;

- (id)initWithURL:(NSURL *)aURL Name:(NSString *)anName;

- (void)setVolume:(float)v;
- (void)setVolumeByRatio:(float)ratio forWhole:(BOOL)isWhole;
- (void)setVolumeByOffset:(float)offset forWhole:(BOOL)isWhole;

- (void)setSourceStart:(CMTime)start Duration:(CMTime)duration;
- (void)setSourceStart:(CMTime)start End:(CMTime)end;
- (void)setTargetPosition:(CMTime)position;
- (void)setTargetDuration:(CMTime)duration;

- (BOOL)checkTimeRange:(CMTime)start Duration:(CMTime)duration;
- (BOOL)checkDuration:(CMTime)duration;
- (BOOL)checkTime:(CMTime)position;

- (void)addBeginVolumeRampWithDuration:(CMTime)duration;
- (void)addEndVolumeRampWithDuration:(CMTime)duration;

- (void)addBeginVolumeRampWithRatio:(float)ratio;
- (void)addEndVolumeRampWithRatio:(float)ratio;

+ (id)trackWithURL:(NSURL *)aURL Name:(NSString *)anName;
@end

#pragma mark - RFAudioMixer

@interface RFAudioMixer : NSObject
{
	
}
@property (nonatomic, readonly) NSMutableArray *tracks;

- (id)init;

- (void)addAudioMixTrack:(RFAudioMixTrack *)track;

- (AVPlayerItem *)avPlayerItem;

@end

