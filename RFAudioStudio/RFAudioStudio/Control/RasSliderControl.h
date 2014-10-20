//
//  RasSliderControl.h
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-20.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RasSliderControl : UIControl
{

}
@property (nonatomic, assign) CGFloat lmtStartX;
@property (nonatomic, assign) CGFloat lmtEndX;
@property (nonatomic, assign) CGFloat lmtStartY;
@property (nonatomic, assign) CGFloat lmtEndY;

- (void)setLimtStartX:(CGFloat)sx endX:(CGFloat)ex startY:(CGFloat)sy endY:(CGFloat)ey;

@end
