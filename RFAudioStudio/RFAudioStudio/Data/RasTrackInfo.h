//
//  RasTrackInfo.h
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-19.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, RasTrackLocation)
{
	RasTrackLocationNone = 0,
	RasTrackLocationDocument,
	RasTrackLocationTmp,
	RasTrackLocationCache,
	RasTrackLocationItunes,
	RasTrackLocationNet,
};

@interface RasTrackInfo : NSObject
{

}
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) RasTrackLocation location;
@property (nonatomic, assign) NSDate *date;

- (AVURLAsset *)assert;
- (AVPlayerItem *)avPlayerItem;

@end
