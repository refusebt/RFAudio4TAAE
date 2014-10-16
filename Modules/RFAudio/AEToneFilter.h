//
//  AEToneFilter.h
//  RFAudio For TAAE
//
//  Created by GZH on 14-3-24.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"

@interface AEToneFilter : NSObject <AEAudioFilter>
{
}
@property (nonatomic, assign) double theta;
@property (nonatomic, assign) double sampleRate;
@property (nonatomic, assign) double frequency;

- (AEAudioControllerFilterCallback)filterCallback;

@end
