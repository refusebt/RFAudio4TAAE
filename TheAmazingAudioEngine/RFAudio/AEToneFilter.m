//
//  AEToneFilter.m
//  RFAudio For TAAE
//
//  Created by GZH on 14-3-24.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import "AEToneFilter.h"
#import "SmbPitchShift.h"

@interface AEToneFilter ()
{
	
}

static OSStatus filterCallback(id                        filter,
                               AEAudioController        *audioController,
                               AEAudioControllerFilterProducer producer,
                               void                     *producerToken,
                               const AudioTimeStamp     *time,
                               UInt32                    frames,
                               AudioBufferList          *audio);

@end

@implementation AEToneFilter
@synthesize theta = _theta;
@synthesize sampleRate = _sampleRate;
@synthesize frequency = _frequency;

- (id)init
{
    if ( !(self = [super init]) )
		return nil;
	
	_theta = 0.0f;
	_sampleRate = 44100.0f;
	_frequency = 1.0f;
	
    return self;
}

- (void)dealloc
{
	
}

- (AEAudioControllerFilterCallback)filterCallback
{
    return filterCallback;
}

static OSStatus filterCallback(id                        filter,
                               AEAudioController        *audioController,
                               AEAudioControllerFilterProducer producer,
                               void                     *producerToken,
                               const AudioTimeStamp     *time,
                               UInt32                    frames,
                               AudioBufferList          *audio)
{
    OSStatus status = producer(producerToken, audio, &frames);
    if ( status != noErr ) return status;
	
	static vDSP_Length n = 0;
	static FFTSetup setup = NULL;
	
	if (setup == NULL)
	{
		n = log2f( ( float) frames );
		setup = vDSP_create_fftsetup(n, FFT_RADIX2);
	}
	
	AEToneFilter *THIS = filter;
	for (NSInteger i = 0; i < audio->mNumberBuffers; i++)
	{
		AudioBuffer audioBuffer = audio->mBuffers[i];
		int16_t *buffer = (int16_t *)audioBuffer.mData;
		float fbuf[frames];
		
		memset(fbuf, 0, frames*sizeof(float));
		
		vDSP_vflt16(buffer, 1, fbuf, 1, frames);
		
		// 算法效果不好，性能问题
		float frequency = 0.0f;
		smb2PitchShift(THIS->_frequency, frames, 128, 4, audioController.audioDescription.mSampleRate, fbuf, fbuf, setup, &frequency);
		
		vDSP_vfix16(fbuf, 1, buffer, 1, frames);
	}
	
    return noErr;
}

@end
