//
//  AEOutputConvert.h
//  RFAudio For TAAE
//
//  Created by GZH on 14-4-3.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"

@class AEOutputConvert;

typedef enum tagAEOutputConvertType
{
	AEOutputConvertTypeWAVE = 0,
	AEOutputConvertTypeALAW = 1,
	AEOutputConvertTypeAAC = 2,
}
AEOutputConvertType;

@interface AEOutputConvert : NSObject <AEAudioReceiver>
{
	
}
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) AEOutputConvertType convertType;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) BOOL isError;
@property (nonatomic, copy) void(^progressBlock)(NSTimeInterval currentTime);
@property (nonatomic, copy) void(^finishBlock)(BOOL isError);

- (id)initWithAudioController:(AEAudioController *)anAudioController path:(NSString *)aPath type:(AEOutputConvertType)aType;

- (BOOL)prepareWithProgress:(void(^)(NSTimeInterval currentTime))aProgressBlock
					 finish:(void(^)(BOOL isError))aFinishBlock;
- (void)stopConvert;

+ (BOOL)AACEncodingAvailable;

@end
