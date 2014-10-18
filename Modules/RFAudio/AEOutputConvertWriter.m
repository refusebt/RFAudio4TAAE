//
//  AEOutputConvertWriter.m
//  RFAudio For TAAE
//
//  Created by GZH on 14-4-3.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import "AEOutputConvertWriter.h"

#define checkResult(result,operation) (_checkResult((result),(operation),strrchr(__FILE__, '/')+1,__LINE__))
static inline BOOL _checkResult(OSStatus result, const char *operation, const char* file, int line)
{
    if ( result != noErr )
	{
        NSLog(@"%s:%d: %s result %d %08X %4.4s\n", file, line, operation, (int)result, (int)result, (char*)&result);
        return NO;
    }
    return YES;
}

@interface AEOutputConvertWriter ()
{
	BOOL _writing;
    ExtAudioFileRef _audioFile;
    UInt32 _priorMixOverrideValue;
}

@end

@implementation AEOutputConvertWriter
@synthesize srcDesc = _srcDesc;
@synthesize destDesc = _destDesc;
@synthesize path = _path;
@synthesize audioFileTypeID = _audioFileTypeID;

- (id)initWithSrc:(AudioStreamBasicDescription *)pSrc dest:(AudioStreamBasicDescription *)pDest path:(NSString*)aPath fileType:(AudioFileTypeID)aFileType
{
	if (!(self = [super init]))
		return nil;
	
    _srcDesc = *pSrc;
	_destDesc = *pDest;
	_path = aPath;
	_audioFileTypeID = aFileType;
	
    return self;
}

- (void)dealloc
{
	if (_writing)
	{
		[self finishWriting];
	}
}

- (BOOL)beginWriting:(NSError**)error
{
	OSStatus status;
    
    if (_audioFileTypeID == kAudioFileM4AType)
	{
        if (![AEAudioFileWriter AACEncodingAvailable])
		{
            if (error) *error = [NSError errorWithDomain:AEAudioFileWriterErrorDomain
													code:kAEAudioFileWriterFormatError
												userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"AAC Encoding not available", @"")
																					 forKey:NSLocalizedDescriptionKey]];
            
            return NO;
        }
        
        // AAC won't work if the 'mix with others' session property is enabled. Disable it if it's on.
        UInt32 size = sizeof(_priorMixOverrideValue);
        checkResult(AudioSessionGetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, &size, &_priorMixOverrideValue),
                    "AudioSessionGetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers)");
        
        if (_priorMixOverrideValue != NO)
		{
            UInt32 allowMixing = NO;
            checkResult(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (allowMixing), &allowMixing),
                        "AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers)");
        }
        
        // Create the file
        status = ExtAudioFileCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:_path],
                                           _audioFileTypeID,
                                           &_destDesc,
                                           NULL,
                                           kAudioFileFlags_EraseFile,
                                           &_audioFile);
        
        if (!checkResult(status, "ExtAudioFileCreateWithURL"))
		{
            int fourCC = CFSwapInt32HostToBig(status);
            if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain
													code:status
												userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:NSLocalizedString(@"Couldn't open the output file (error %d/%4.4s)", @""), status, (char*)&fourCC]
																					 forKey:NSLocalizedDescriptionKey]];
            return NO;
        }
        
        UInt32 codecManfacturer = kAppleSoftwareAudioCodecManufacturer;
        status = ExtAudioFileSetProperty(_audioFile, kExtAudioFileProperty_CodecManufacturer, sizeof(UInt32), &codecManfacturer);
        
        if (!checkResult(status, "ExtAudioFileSetProperty(kExtAudioFileProperty_CodecManufacturer"))
		{
            int fourCC = CFSwapInt32HostToBig(status);
            if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                    code:status
                                                userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:NSLocalizedString(@"Couldn't set audio codec (error %d/%4.4s)", @""), status, (char*)&fourCC]
                                                                                     forKey:NSLocalizedDescriptionKey]];
            ExtAudioFileDispose(_audioFile);
            return NO;
        }
    }
	else if (_audioFileTypeID == kAudioFileWAVEType)
	{
        // Create the file
        status = ExtAudioFileCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:_path],
                                           _audioFileTypeID,
                                           &_destDesc,
                                           NULL,
                                           kAudioFileFlags_EraseFile,
                                           &_audioFile);
        
        if (!checkResult(status, "ExtAudioFileCreateWithURL"))
		{
            int fourCC = CFSwapInt32HostToBig(status);
            if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain
													code:status
												userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:NSLocalizedString(@"Couldn't open the output file (error %d/%4.4s)", @""), status, (char*)&fourCC]
																					 forKey:NSLocalizedDescriptionKey]];
            return NO;
        }
    }
    
    // Set up the converter
    status = ExtAudioFileSetProperty(_audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &_srcDesc);
    if (!checkResult(status, "ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat"))
	{
        int fourCC = CFSwapInt32HostToBig(status);
        if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain
												code:status
											userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:NSLocalizedString(@"Couldn't configure the converter (error %d/%4.4s)", @""), status, (char*)&fourCC]
																				 forKey:NSLocalizedDescriptionKey]];
        ExtAudioFileDispose(_audioFile);
        return NO;
    }
    
    // Init the async file writing mechanism
    checkResult(ExtAudioFileWriteAsync(_audioFile, 0, NULL), "ExtAudioFileWriteAsync");
    
    _writing = YES;
    
    return YES;
}

- (OSStatus)writerAudio:(AudioBufferList *)bufferList frames:(UInt32)lengthInFrames
{
	return ExtAudioFileWriteAsync(_audioFile, lengthInFrames, bufferList);
}

- (OSStatus)writerSyncAudio:(AudioBufferList *)bufferList frames:(UInt32)lengthInFrames
{
	return ExtAudioFileWrite(_audioFile, lengthInFrames, bufferList);
}

- (void)finishWriting
{
    if (!_writing)
		return;
	
    _writing = NO;
    
    checkResult(ExtAudioFileDispose(_audioFile), "AudioFileClose");
    
    if (_priorMixOverrideValue)
	{
        checkResult(AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(_priorMixOverrideValue), &_priorMixOverrideValue),
                    "AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers)");
    }
}

@end
