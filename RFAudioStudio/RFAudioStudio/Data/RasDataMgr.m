//
//  RasDataMgr.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasDataMgr.h"

@implementation RasDataMgr

- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (void)load
{
	
}

- (void)save
{
	
}

+ (RasDataMgr *)shared
{
	static RasDataMgr *s_instance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		s_instance = [[RasDataMgr alloc] init];
	});
	
	return s_instance;
}
@end
