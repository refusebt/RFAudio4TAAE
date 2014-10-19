//
//  RasDataMgr.h
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-18.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RasDataMgr : NSObject
{

}

- (void)load;
- (void)save;

+ (RasDataMgr *)shared;

@end
