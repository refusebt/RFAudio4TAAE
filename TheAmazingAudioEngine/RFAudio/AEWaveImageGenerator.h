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

@class AEWaveImageGenerator;

typedef void(^AEWaveImageGeneratorBlock)(AEWaveImageGenerator *generator);

@interface AEWaveImageGenerator : NSObject <AEAudioReceiver>
{

}
// int
@property (nonatomic, assign) BOOL isHeightMax;				// max sample value is height
@property (nonatomic, copy) AEWaveImageGeneratorBlock startBlock;
@property (nonatomic, copy) AEWaveImageGeneratorBlock finishBlock;
// out
@property (nonatomic, strong) UIImage *waveImage;

- (id)initWithAudioController:(AEAudioController *)audioController
						width:(NSInteger)width
					   height:(NSInteger)height
					 duration:(NSTimeInterval)duration
						color:(UIColor *)color;

+ (AEWaveImageGenerator *)waveImageWithAssert:(AVURLAsset *)assert
										 size:(CGSize)size
										color:(UIColor *)color
								  isHeightMax:(BOOL)isHeightMax
										start:(AEWaveImageGeneratorBlock)startBlock
									   finish:(AEWaveImageGeneratorBlock)finishBlock
;

@end
