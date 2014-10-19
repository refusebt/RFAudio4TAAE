//
//  RFAudioKit.m
//  RFAudio For TAAE
//
//  Created by GZH on 14-10-16.
//  Copyright (c) 2014年 GZH. All rights reserved.
//

#import "RFAudioKit.h"

#define DEF_ERROR(error, msg)	\
	case error:	\
		(msg) = #error;	\
		break;

#define ALAW_TAG_DATA					"data"
static char ALAW_TAG_FACT_CONTENT[] =
{
	'f', 'a', 'c', 't',
	4, 0, 0, 0, 0, 83, 7, 0
};

@implementation RFAudioKit

+ (OSStatus)SkyOSStatusAudioWithError:(OSStatus)error file:(char *)file lineNo:(NSInteger)lineNo
{
	if (error != noErr) 
	{
		char* msg = NULL;
		switch (error)
		{
			// AT
			DEF_ERROR(kAudioFileUnspecifiedError, msg)
			DEF_ERROR(kAudioFileUnsupportedFileTypeError, msg)
			DEF_ERROR(kAudioFileUnsupportedDataFormatError, msg)
			DEF_ERROR(kAudioFileUnsupportedPropertyError, msg)
			DEF_ERROR(kAudioFileBadPropertySizeError, msg)
			DEF_ERROR(kAudioFilePermissionsError, msg)
			DEF_ERROR(kAudioFileNotOptimizedError, msg)
			DEF_ERROR(kAudioFileInvalidChunkError, msg)
			DEF_ERROR(kAudioFileDoesNotAllow64BitDataSizeError, msg)
			DEF_ERROR(kAudioFileInvalidPacketOffsetError, msg)
			DEF_ERROR(kAudioFileInvalidFileError, msg)
			DEF_ERROR(kAudioFileOperationNotSupportedError, msg)
			DEF_ERROR(kAudioFileNotOpenError, msg)
			DEF_ERROR(kAudioFileEndOfFileError, msg)
			DEF_ERROR(kAudioFilePositionError, msg)
			DEF_ERROR(kAudioFileFileNotFoundError, msg)
//			DEF_ERROR(kAudioFileStreamError_UnsupportedFileType, msg)
//			DEF_ERROR(kAudioFileStreamError_UnsupportedDataFormat, msg)
//			DEF_ERROR(kAudioFileStreamError_UnsupportedProperty, msg)
//			DEF_ERROR(kAudioFileStreamError_BadPropertySize, msg)
//			DEF_ERROR(kAudioFileStreamError_NotOptimized, msg)
//			DEF_ERROR(kAudioFileStreamError_InvalidPacketOffset, msg)
//			DEF_ERROR(kAudioFileStreamError_InvalidFile, msg)
			DEF_ERROR(kAudioFileStreamError_ValueUnknown, msg)
			DEF_ERROR(kAudioFileStreamError_DataUnavailable, msg)
			DEF_ERROR(kAudioFileStreamError_IllegalOperation, msg)
//			DEF_ERROR(kAudioFileStreamError_UnspecifiedError, msg)
			DEF_ERROR(kAudioFileStreamError_DiscontinuityCantRecover, msg)
			DEF_ERROR(kAudioFormatUnspecifiedError, msg)
			DEF_ERROR(kAudioFormatUnsupportedPropertyError, msg)
//			DEF_ERROR(kAudioFormatBadPropertySizeError, msg)
			DEF_ERROR(kAudioFormatBadSpecifierSizeError, msg)
//			DEF_ERROR(kAudioFormatUnsupportedDataFormatError, msg)
			DEF_ERROR(kAudioFormatUnknownFormatError, msg)
			DEF_ERROR(kAudioServicesNoError, msg)
//			DEF_ERROR(kAudioServicesUnsupportedPropertyError, msg)
//			DEF_ERROR(kAudioServicesBadPropertySizeError, msg)
//			DEF_ERROR(kAudioServicesBadSpecifierSizeError, msg)
			DEF_ERROR(kAudioServicesSystemSoundUnspecifiedError, msg)
			DEF_ERROR(kAudioServicesSystemSoundClientTimedOutError, msg)
//			DEF_ERROR(kAudioSessionNoError, msg)
			DEF_ERROR(kAudioSessionNotInitialized, msg)
			DEF_ERROR(kAudioSessionAlreadyInitialized, msg)
			DEF_ERROR(kAudioSessionInitializationError, msg)
//			DEF_ERROR(kAudioSessionUnsupportedPropertyError, msg)
//			DEF_ERROR(kAudioSessionBadPropertySizeError, msg)
			DEF_ERROR(kAudioSessionNotActiveError, msg)
			DEF_ERROR(kAudioServicesNoHardwareError, msg)
			DEF_ERROR(kAudioSessionNoCategorySet, msg)
			DEF_ERROR(kAudioSessionIncompatibleCategory, msg)
//			DEF_ERROR(kAudioSessionUnspecifiedError, msg)
//			DEF_ERROR(kAudioSessionNoError, msg)
//			DEF_ERROR(kAudioSessionNotInitialized, msg)
//			DEF_ERROR(kAudioSessionAlreadyInitialized, msg)
//			DEF_ERROR(kAudioSessionInitializationError, msg)
//			DEF_ERROR(kAudioSessionUnsupportedPropertyError, msg)
//			DEF_ERROR(kAudioSessionBadPropertySizeError, msg)
//			DEF_ERROR(kAudioSessionNotActiveError, msg)
//			DEF_ERROR(kAudioServicesNoHardwareError, msg)
//			DEF_ERROR(kAudioSessionNoCategorySet, msg)
//			DEF_ERROR(kAudioSessionIncompatibleCategory, msg)
//			DEF_ERROR(kAudioSessionUnspecifiedError, msg)
			DEF_ERROR(kAUGraphErr_NodeNotFound, msg)
			DEF_ERROR(kAUGraphErr_InvalidConnection, msg)
			DEF_ERROR(kAUGraphErr_OutputNodeErr, msg)
			DEF_ERROR(kAUGraphErr_CannotDoInCurrentContext, msg)
			DEF_ERROR(kAUGraphErr_InvalidAudioUnit, msg)
			DEF_ERROR(kAudio_UnimplementedError, msg)
//			DEF_ERROR(kAudio_FileNotFoundError, msg)
			DEF_ERROR(kAudio_ParamError, msg)
			DEF_ERROR(kAudio_MemFullError, msg)
//			DEF_ERROR(kAudioConverterErr_FormatNotSupported, msg)
//			DEF_ERROR(kAudioConverterErr_OperationNotSupported, msg)
//			DEF_ERROR(kAudioConverterErr_PropertyNotSupported, msg)
			DEF_ERROR(kAudioConverterErr_InvalidInputSize, msg)
			DEF_ERROR(kAudioConverterErr_InvalidOutputSize, msg)
//			DEF_ERROR(kAudioConverterErr_UnspecifiedError, msg)
//			DEF_ERROR(kAudioConverterErr_BadPropertySizeError, msg)
			DEF_ERROR(kAudioConverterErr_RequiresPacketDescriptionsError, msg)
			DEF_ERROR(kAudioConverterErr_InputSampleRateOutOfRange, msg)
			DEF_ERROR(kAudioConverterErr_OutputSampleRateOutOfRange, msg)
			DEF_ERROR(kAudioConverterErr_HardwareInUse, msg)
			DEF_ERROR(kAudioConverterErr_NoHardwarePermission, msg)
			DEF_ERROR(kExtAudioFileError_CodecUnavailableInputConsumed, msg)
			DEF_ERROR(kExtAudioFileError_CodecUnavailableInputNotConsumed, msg)
			DEF_ERROR(kExtAudioFileError_InvalidProperty, msg)
			DEF_ERROR(kExtAudioFileError_InvalidPropertySize, msg)
			DEF_ERROR(kExtAudioFileError_NonPCMClientFormat, msg)
			DEF_ERROR(kExtAudioFileError_InvalidChannelMap, msg)
			DEF_ERROR(kExtAudioFileError_InvalidOperationOrder, msg)
			DEF_ERROR(kExtAudioFileError_InvalidDataFormat, msg)
			DEF_ERROR(kExtAudioFileError_MaxPacketSizeUnknown, msg)
			DEF_ERROR(kExtAudioFileError_InvalidSeek, msg)
			DEF_ERROR(kExtAudioFileError_AsyncWriteTooLarge, msg)
			DEF_ERROR(kExtAudioFileError_AsyncWriteBufferOverflow, msg)
			// AU
			DEF_ERROR(kAudioUnitErr_InvalidProperty, msg)
			DEF_ERROR(kAudioUnitErr_InvalidParameter, msg)
			DEF_ERROR(kAudioUnitErr_InvalidElement, msg)
			DEF_ERROR(kAudioUnitErr_NoConnection, msg)
			DEF_ERROR(kAudioUnitErr_FailedInitialization, msg)
			DEF_ERROR(kAudioUnitErr_TooManyFramesToProcess, msg)
			DEF_ERROR(kAudioUnitErr_InvalidFile, msg)
			DEF_ERROR(kAudioUnitErr_FormatNotSupported, msg)
			DEF_ERROR(kAudioUnitErr_Uninitialized, msg)
			DEF_ERROR(kAudioUnitErr_InvalidScope, msg)
			DEF_ERROR(kAudioUnitErr_PropertyNotWritable, msg)
//			DEF_ERROR(kAudioUnitErr_CannotDoInCurrentContext, msg)
			DEF_ERROR(kAudioUnitErr_InvalidPropertyValue, msg)
			DEF_ERROR(kAudioUnitErr_PropertyNotInUse, msg)
			DEF_ERROR(kAudioUnitErr_Initialized, msg)
			DEF_ERROR(kAudioUnitErr_InvalidOfflineRender, msg)
			DEF_ERROR(kAudioUnitErr_Unauthorized, msg)
			DEF_ERROR(kAudioUnitErr_IllegalInstrument, msg)
			DEF_ERROR(kAudioUnitErr_InstrumentTypeNotFound, msg)
			DEF_ERROR(kAudioUnitErr_UnknownFileType, msg)
			DEF_ERROR(kAudioUnitErr_FileNotSpecified, msg)
			// CM
//			DEF_ERROR(kAudio_UnimplementedError, msg)
//			DEF_ERROR(kAudio_FileNotFoundError, msg)
//			DEF_ERROR(kAudio_ParamError, msg)
//			DEF_ERROR(kAudio_MemFullError, msg)
			DEF_ERROR(kCMSampleBufferError_AllocationFailed, msg)
			DEF_ERROR(kCMSampleBufferError_RequiredParameterMissing, msg)
			DEF_ERROR(kCMSampleBufferError_AlreadyHasDataBuffer, msg)
			DEF_ERROR(kCMSampleBufferError_BufferNotReady, msg)				
			DEF_ERROR(kCMSampleBufferError_SampleIndexOutOfRange, msg)	
			DEF_ERROR(kCMSampleBufferError_BufferHasNoSampleSizes, msg)
			DEF_ERROR(kCMSampleBufferError_BufferHasNoSampleTimingInfo, msg)
			DEF_ERROR(kCMSampleBufferError_ArrayTooSmall, msg)
			DEF_ERROR(kCMSampleBufferError_InvalidEntryCount, msg)				
			DEF_ERROR(kCMSampleBufferError_CannotSubdivide, msg)	
			DEF_ERROR(kCMSampleBufferError_SampleTimingInfoInvalid, msg)
			DEF_ERROR(kCMSampleBufferError_InvalidMediaTypeForOperation, msg)
			DEF_ERROR(kCMSampleBufferError_InvalidSampleData, msg)
			DEF_ERROR(kCMSampleBufferError_InvalidMediaFormat, msg)				
			DEF_ERROR(kCMSampleBufferError_Invalidated, msg)
			default:
				msg = "unknown";
				break;
		}
		NSLog(@"File:%s:%ld; Msg:%s; OSStatus:%ld", file, (long)lineNo, msg, (long)error);
	}
	return error;
}

+ (BOOL)correctAlawHeader:(NSURL *)fileUrl
{
	NSData *data = [NSData dataWithContentsOfURL:fileUrl];
	if (data != NULL)
	{
		char *fileBuf = (char *)[data bytes];
		if (fileBuf != NULL)
		{
			int dataOffset = -1;
			
			// 找到data
			NSUInteger searchSize = [data length] - strlen(ALAW_TAG_DATA);
			for (int i = 0; i < searchSize ; i++)
			{
				char *pos = fileBuf + i;
				if (strcmp(pos, ALAW_TAG_DATA) == 0)
				{
					// found
					dataOffset = i;
					break;
				}
			}
			
			if (dataOffset == -1)
			{
				NSLog(@"ALAW头修正失败");
				return NO;
			}
			
			// 拼接
			NSMutableData *newFileData = [NSMutableData data];
			[newFileData appendBytes:fileBuf length:0x24];					// 到量化数
			[newFileData appendBytes:"\0\0" length:2*sizeof(char)];			// 因为10->12 占位
			[newFileData appendBytes:ALAW_TAG_FACT_CONTENT length:sizeof(ALAW_TAG_FACT_CONTENT)];	// fact
			[newFileData appendBytes:(fileBuf + dataOffset) length:([data length] - dataOffset)];	// data
			
			// 修正文件头
			// 0x04H处 文件总长修正 full-8
			{
				NSUInteger value = [newFileData length] - 8;
				[newFileData replaceBytesInRange:NSMakeRange(0x4, 4) withBytes:&value];
			}
			
			// 0x10H处 10->12
			{
				char value = 0x12;
				[newFileData replaceBytesInRange:NSMakeRange(0x10, 1) withBytes:&value];
			}
			
			// 0x36H处 采样数据字节数 full - 58
			{
				NSUInteger value = [newFileData length] - 58;
				[newFileData replaceBytesInRange:NSMakeRange(0x36, 4) withBytes:&value];
			}
			
			[newFileData writeToURL:fileUrl atomically:YES];
			return YES;
		}
	}
	return NO;
}

@end
