//
//  RasTrackEditorControl.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-20.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasTrackEditorControl.h"

@interface RasTrackEditorControl ()
{
	CGFloat _sliderSide;
	CGFloat _sx;
	CGFloat _ex;
	CGFloat _sy;
	CGFloat _ey;
}

@end

@implementation RasTrackEditorControl

- (void)awakeFromNib
{
	CGRect rect = self.frame;
	
	_sliderSide = 20;
	_sx = _sliderSide / 2;
	_ex = rect.size.width - _sliderSide/2;
	_sy = _sliderSide / 2;
	_ey = rect.size.height - _sliderSide/2;
	
	self.backgroundColor = [UIColor clearColor];
	
	self.imgViewWave = [[UIImageView alloc] initWithFrame:CGRectMake(_sx, _sy, _ex-_sx, _ey-_sy)];
	self.imgViewWave.backgroundColor = RGBA2COLOR(230, 230, 230, 1);
	[self addSubview:self.imgViewWave];
	
	self.topLeftSlider = [[RasSliderControl alloc] initWithFrame:CGRectMake(0, 0, _sliderSide, _sliderSide)];
	self.topLeftSlider.center = CGPointMake(_sx, _sy);
	[self.topLeftSlider setLimtStartX:_sx endX:_ex startY:_sy endY:_sy];
	[self addSubview:self.topLeftSlider];
	
	self.topRightSlider = [[RasSliderControl alloc] initWithFrame:CGRectMake(0, 0, _sliderSide, _sliderSide)];
	self.topRightSlider.center = CGPointMake(_ex, _sy);
	[self.topRightSlider setLimtStartX:_sx endX:_ex startY:_sy endY:_sy];
	[self addSubview:self.topRightSlider];
	
	self.bottomLeftSlider = [[RasSliderControl alloc] initWithFrame:CGRectMake(0, 0, _sliderSide, _sliderSide)];
	self.bottomLeftSlider.center = CGPointMake(_sx, _ey);
	[self.bottomLeftSlider setLimtStartX:_sx endX:_ex startY:_ey endY:_ey];
	[self addSubview:self.bottomLeftSlider];
	
	self.bottomRightSlider = [[RasSliderControl alloc] initWithFrame:CGRectMake(0, 0, _sliderSide, _sliderSide)];
	self.bottomRightSlider.center = CGPointMake(_ex, _ey);
	[self.bottomRightSlider setLimtStartX:_sx endX:_ex startY:_ey endY:_ey];
	[self addSubview:self.bottomRightSlider];
	
	[self borderOrange];
}

@end
