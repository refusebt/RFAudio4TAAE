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
	_frequency = 2.0f;
	
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
    
	const int size = 512;
	static vDSP_Length n = 0;
	static FFTSetup setup = NULL;
	float frequency = 0.0f;
	
	if (setup == NULL)
	{
		n = log2f( ( float) size );
		setup = vDSP_create_fftsetup(n, FFT_RADIX2);
	}
	
	AEToneFilter *THIS = filter;
	const int channel = 0;
	int16_t *buffer = (int16_t *)audio->mBuffers[channel].mData;
	float fbuf[512];
	
	memset(fbuf, 0, sizeof(fbuf));
	vDSP_vflt16(buffer, 1, fbuf, 1, 512);
	
	smb2PitchShift(THIS->_frequency, frames, 128, 4, THIS->_sampleRate, fbuf, fbuf, setup, &frequency);
	
	vDSP_vfix16(fbuf, 1, buffer, 1, 512);
	
    return noErr;
}

@end
