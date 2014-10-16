//
//  SmbPitchShift.h
//  RFAudio For TAAE
//
//  Created by GZH on 14-3-26.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#ifndef TheEngineSample_SmbPitchShift_h
#define TheEngineSample_SmbPitchShift_h

#import <Accelerate/Accelerate.h>

extern void smbPitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize, long osamp,
						  float sampleRate, float *indata, float *outdata);
extern void smb2PitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize, long osamp,
						   float sampleRate, float *indata, float *outdata,
						   FFTSetup fftSetup, float *frequency);

#endif
