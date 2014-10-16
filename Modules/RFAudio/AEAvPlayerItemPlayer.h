//
//  AEAvPlayerItemPlayer.h
//  RFAudio For TAAE
//
//  Created by GZH on 14-3-31.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AEAudioController.h"
#import "AEAssetReader.h"

@interface AEAvPlayerItemPlayer : NSObject <AEAudioPlayable>
{
	
}
@property (nonatomic, strong) AVPlayerItem *avPlayerItem;
@property (nonatomic, readonly) NSTimeInterval duration;    //!< Length of audio, in seconds
@property (nonatomic, assign) NSTimeInterval currentTime;   //!< Current playback position, in seconds
@property (nonatomic, assign) float volume;              //!< Track volume
@property (nonatomic, assign) float pan;                 //!< Track pan
@property (nonatomic, assign) BOOL channelIsPlaying;     //!< Whether the track is playing
@property (nonatomic, assign) BOOL channelIsMuted;       //!< Whether the track is muted
@property (nonatomic, copy) void(^progressBlock)(NSTimeInterval currentTime, NSTimeInterval duration);
@property (nonatomic, copy) void(^finishBlock)();

- (id)initWithWithItem:(AVPlayerItem *)anItem audioController:(AEAudioController *)anAudioController;

- (BOOL)prepareWithProgress:(void(^)(NSTimeInterval currentTime, NSTimeInterval duration))aProgressBlock
					 finish:(void(^)())aFinishBlock;

@end
