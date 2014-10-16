//
//  RFAudioKit.m
//  TheAmazingAudioEngine
//
//  Created by gouzhehua on 14-10-16.
//  Copyright (c) 2014年 A Tasty Pixel. All rights reserved.
//

#import "RFAudioKit.h"

#define ALAW_TAG_DATA					"data"
static char ALAW_TAG_FACT_CONTENT[] =
{
	'f', 'a', 'c', 't',
	4, 0, 0, 0, 0, 83, 7, 0
};

@implementation RFAudioKit

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
