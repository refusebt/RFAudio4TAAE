//
//  AEWaveImageGenerator.h
//  TheAmazingAudioEngine
//
//  Created by gouzhehua on 14-10-19.
//  Copyright (c) 2014年 A Tasty Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TheAmazingAudioEngine.h"

@interface AEWaveImageGenerator : NSObject <AEAudioReceiver>
{

}
// int
@property (nonatomic, copy) void(^finish)(UIImage *image);
// out
@property (nonatomic, strong) UIImage *waveImage;

- (id)initWithAudioController:(AEAudioController *)audioController
						width:(NSInteger)width
					   height:(NSInteger)height
					 duration:(NSTimeInterval)duration
						color:(UIColor *)color;

@end
