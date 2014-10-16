//
//  AEOutputConvertWriter.h
//  RFAudio For TAAE
//
//  Created by GZH on 14-4-3.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TheAmazingAudioEngine.h"

@interface AEOutputConvertWriter : NSObject
{
	
}
@property (nonatomic, assign) AudioStreamBasicDescription srcDesc;
@property (nonatomic, readonly) AudioStreamBasicDescription destDesc;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) AudioFileTypeID audioFileTypeID;

- (id)initWithSrc:(AudioStreamBasicDescription *)pSrc dest:(AudioStreamBasicDescription *)pDest path:(NSString*)aPath fileType:(AudioFileTypeID)aFileType;

- (BOOL)beginWriting:(NSError**)error;

- (OSStatus)writerAudio:(AudioBufferList *)bufferList frames:(UInt32)lengthInFrames;
- (OSStatus)writerSyncAudio:(AudioBufferList *)bufferList frames:(UInt32)lengthInFrames;

- (void)finishWriting;

@end
