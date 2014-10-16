//
//  AEAssetReader.h
//  RFAudio For TAAE
//
//  Created by GZH on 14-4-1.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AEAssetReader : NSObject
{

}
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, readonly) int64_t fileSize;
@property (nonatomic, readonly) int64_t fullFrames;
@property (nonatomic, readonly) int64_t byteRate;
@property (nonatomic, readonly) NSString *formatExtension;
@property (nonatomic, readonly) AudioStreamBasicDescription requireAudioDesc;
@property (nonatomic, readonly) AudioStreamBasicDescription outAudioDesc;

- (id)initWithAssert:(AVAsset *)anAsset audioMix:(AVAudioMix *)anAudioMix basicDesc:(AudioStreamBasicDescription *)aDesc;

- (BOOL)isInitialized;

- (BOOL)startWorkWithFramePos:(int64_t)framePos;
- (void)stopWork;

- (UInt32)fillAudioBufferList:(AudioBufferList *)pOutAudioBufferList frames:(UInt32)frames;

@end
