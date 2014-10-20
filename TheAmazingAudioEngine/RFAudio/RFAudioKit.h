//
//  RFAudioKit.h
//  RFAudio For TAAE
//
//  Created by GZH on 14-10-16.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@class AudioKit;

#ifdef __OPTIMIZE__
	#define RF_OSS_AUDIO(error)	error
#else
	#define RF_OSS_AUDIO(error)	[AudioKit SkyOSStatusAudioWithError:error file:__FILE__ lineNo:__LINE__]
#endif

@interface RFAudioKit : NSObject
{
}

+ (OSStatus)SkyOSStatusAudioWithError:(OSStatus)error file:(char *)file lineNo:(NSInteger)lineNo;
+ (BOOL)correctAlawHeader:(NSURL *)fileUrl;

@end
