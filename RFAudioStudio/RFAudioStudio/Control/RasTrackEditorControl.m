//
//  RasTrackEditorControl.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-20.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasTrackEditorControl.h"

@interface RasTrackEditorControl ()
<
	RasSliderControlDelegate
>
{
	CGFloat _sliderSide;
	CGFloat _sx;
	CGFloat _ex;
	CGFloat _sy;
	CGFloat _ey;
}
@property (nonatomic, assign) CGPoint start;

- (void)drawRange;
- (void)restraintWithSlider:(RasSliderControl *)slider;

@end

@implementation RasTrackEditorControl
@synthesize imgViewWave = _imgViewWave;
@synthesize imgViewRange = _imgViewRange;
@synthesize topLeftSlider = _topLeftSlider;
@synthesize topRightSlider = _topRightSlider;
@synthesize bottomLeftSlider = _bottomLeftSlider;
@synthesize bottomRightSlider = _bottomRightSlider;
@synthesize start = _start;

- (void)awakeFromNib
{
	CGRect rect = self.frame;
	
	_sliderSide = 30;
	_sx = _sliderSide / 2;
	_ex = rect.size.width - _sliderSide/2;
	_sy = _sliderSide / 2;
	_ey = rect.size.height - _sliderSide/2;
	
	self.backgroundColor = [UIColor clearColor];
	
	_imgViewWave = [[UIImageView alloc] initWithFrame:CGRectMake(_sx, _sy, _ex-_sx, _ey-_sy)];
	_imgViewWave.backgroundColor = RGBA2COLOR(230, 230, 230, 1);
	[self addSubview:_imgViewWave];
	
	_imgViewRange = [[UIImageView alloc] initWithFrame:self.bounds];
	_imgViewRange.backgroundColor = [UIColor clearColor];
	[self addSubview:_imgViewRange];
	
	_topLeftSlider = [[RasSliderControl alloc] initWithFrame:CGRectMake(0, 0, _sliderSide, _sliderSide)];
	_topLeftSlider.center = CGPointMake(_sx, _sy);
	_topLeftSlider.delegate = self;
	[_topLeftSlider setLimtStartX:_sx endX:_ex startY:_sy endY:_sy];
	[self addSubview:_topLeftSlider];
	
	_topRightSlider = [[RasSliderControl alloc] initWithFrame:CGRectMake(0, 0, _sliderSide, _sliderSide)];
	_topRightSlider.center = CGPointMake(_ex, _sy);
	_topRightSlider.delegate = self;
	[_topRightSlider setLimtStartX:_sx endX:_ex startY:_sy endY:_sy];
	[self addSubview:_topRightSlider];
	
	_bottomLeftSlider = [[RasSliderControl alloc] initWithFrame:CGRectMake(0, 0, _sliderSide, _sliderSide)];
	_bottomLeftSlider.center = CGPointMake(_sx, _ey);
	_bottomLeftSlider.delegate = self;
	[_bottomLeftSlider setLimtStartX:_sx endX:_ex startY:_ey endY:_ey];
	[self addSubview:_bottomLeftSlider];
	
	_bottomRightSlider = [[RasSliderControl alloc] initWithFrame:CGRectMake(0, 0, _sliderSide, _sliderSide)];
	_bottomRightSlider.center = CGPointMake(_ex, _ey);
	_bottomRightSlider.delegate = self;
	[_bottomRightSlider setLimtStartX:_sx endX:_ex startY:_ey endY:_ey];
	[self addSubview:_bottomRightSlider];
	
	self.topLeftSlider.backgroundColor = [UIColor redColor];
	self.topRightSlider.backgroundColor = [UIColor yellowColor];
	self.bottomLeftSlider.backgroundColor = [UIColor orangeColor];
	self.bottomRightSlider.backgroundColor = [UIColor purpleColor];
	
	[self drawRange];
}

- (void)drawRange
{
	UIGraphicsBeginImageContextWithOptions(self.imgViewRange.frame.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
//	CGContextSetLineWidth(context, 1);
//	CGContextSetLineCap(context, kCGLineCapRound);
//	[RGBA2COLOR(255, 255, 155, 0.5) set];
	[RGBA2COLOR(255, 255, 155, 0.5) setFill];
	
	CGContextBeginPath(context);
	
	CGPoint point = _topLeftSlider.center;
	CGPoint next = _topRightSlider.center;
	
	CGContextMoveToPoint(context, point.x, point.y);
	CGContextAddLineToPoint(context, next.x, next.y);
	
	next = _bottomRightSlider.center;
	CGContextAddLineToPoint(context, next.x, next.y);
	
	next = _bottomLeftSlider.center;
	CGContextAddLineToPoint(context, next.x, next.y);
	
	next = _topLeftSlider.center;
	CGContextAddLineToPoint(context, next.x, next.y);
	
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFill);
	
	_imgViewRange.image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
}

- (void)restraintWithSlider:(RasSliderControl *)slider
{
	if (slider == _topLeftSlider)
	{
		_topRightSlider.lmtStartX = slider.center.x;
	}
	else if (slider == _topRightSlider)
	{
		_topLeftSlider.lmtEndX = slider.center.x;
	}
	else if (slider == _bottomLeftSlider)
	{
		_bottomRightSlider.lmtStartX = slider.center.x;
		_topLeftSlider.lmtStartX = slider.center.x;
		if (_topLeftSlider.center.x < slider.center.x)
		{
			_topLeftSlider.center = CGPointMake(slider.center.x, _topLeftSlider.center.y);
			_topRightSlider.lmtStartX = slider.center.x;
			if (_topRightSlider.center.x < slider.center.x)
			{
				_topRightSlider.center = CGPointMake(slider.center.x, _topLeftSlider.center.y);
			}
		}
	}
	else if (slider == _bottomRightSlider)
	{
		_bottomLeftSlider.lmtEndX = slider.center.x;
		_topRightSlider.lmtEndX = slider.center.x;
		if (_topRightSlider.center.x > slider.center.x)
		{
			_topRightSlider.center = CGPointMake(slider.center.x, _topRightSlider.center.y);
			_topLeftSlider.lmtEndX = slider.center.x;
			if (_topLeftSlider.center.x > slider.center.x)
			{
				_topLeftSlider.center = CGPointMake(slider.center.x, _topLeftSlider.center.y);
			}
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	_start = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
	CGPoint nowPoint = [touch locationInView:self];
	CGFloat offsetX = nowPoint.x - _start.x;
	
	CGFloat lmtLeft = _bottomLeftSlider.center.x + offsetX;
	if (lmtLeft < _sx)
	{
		return;
	}
	CGFloat lmtRight = _bottomRightSlider.center.x + offsetX;
	if (lmtRight > _ex)
	{
		return;
	}
	
	_start = nowPoint;
	
	NSArray *array = @[_topLeftSlider, _topRightSlider, _bottomLeftSlider, _bottomRightSlider];
	for (RasSliderControl *slider in array)
	{
		CGPoint point = slider.center;
		point.x += offsetX;
		if (point.x < _sx)
		{
			point.x = _sx;
		}
		else if (point.x > _ex)
		{
			point.x = _ex;
		}
		slider.center = point;
		[self restraintWithSlider:slider];
	}
	
	[self drawRange];
}

#pragma mark RasSliderControlDelegate

- (void)onSliderMove:(RasSliderControl *)slider
{
	[self restraintWithSlider:slider];
	[self drawRange];
}

- (void)onSliderMoveEnd:(RasSliderControl *)slider
{
	
}

@end
