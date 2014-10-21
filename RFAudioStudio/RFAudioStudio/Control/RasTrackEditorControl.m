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
- (void)showStatusWithSlider:(RasSliderControl *)slider;
- (void)hideStatus;

@end

@implementation RasTrackEditorControl
@synthesize imgViewWave = _imgViewWave;
@synthesize imgViewRange = _imgViewRange;
@synthesize lbStatus = _lbStatus;
@synthesize topLeftSlider = _topLeftSlider;
@synthesize topRightSlider = _topRightSlider;
@synthesize bottomLeftSlider = _bottomLeftSlider;
@synthesize bottomRightSlider = _bottomRightSlider;
@synthesize start = _start;
@synthesize duration = _duration;

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
	
	_lbStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 16)];
	_lbStatus.backgroundColor = RGBA2COLOR(255, 0, 0, 1);
	[_lbStatus roundedViewWithRadius:8];
	_lbStatus.textAlignment = NSTextAlignmentCenter;
	_lbStatus.text = @"99:99";
	_lbStatus.textColor = RGBA2COLOR(255, 255, 255, 1);
	_lbStatus.font = [UIFont systemFontOfSize:12];
	_lbStatus.alpha = 0;
	_lbStatus.userInteractionEnabled = NO;
	[self addSubview:_lbStatus];
	
	_topLeftSlider.hidden = YES;
	_topRightSlider.hidden = YES;
	_bottomLeftSlider.hidden = YES;
	_bottomRightSlider.hidden = YES;
	_imgViewRange.hidden = YES;
}

- (void)bindWithImage:(UIImage *)image duration:(NSTimeInterval)duration
{
	_imgViewWave.image = image;
	_duration = duration;
	
	_topLeftSlider.hidden = NO;
	_topRightSlider.hidden = NO;
	_bottomLeftSlider.hidden = NO;
	_bottomRightSlider.hidden = NO;
	_imgViewRange.hidden = NO;
	
	_topLeftSlider.center = CGPointMake(_sx, _sy);
	[_topLeftSlider setLimtStartX:_sx endX:_ex startY:_sy endY:_sy];
	
	_topRightSlider.center = CGPointMake(_ex, _sy);
	[_topRightSlider setLimtStartX:_sx endX:_ex startY:_sy endY:_sy];
	
	_bottomLeftSlider.center = CGPointMake(_sx, _ey);
	[_bottomLeftSlider setLimtStartX:_sx endX:_ex startY:_ey endY:_ey];
	
	_bottomRightSlider.center = CGPointMake(_ex, _ey);
	[_bottomRightSlider setLimtStartX:_sx endX:_ex startY:_ey endY:_ey];
	
	[self drawRange];
}

- (CGFloat)ratioWithSlider:(RasSliderControl *)slider
{
	CGFloat full = _ex - _sx;
	CGFloat progress = slider.center.x - _sx;
	if (full == 0)
	{
		return 0;
	}
	return progress/full;
}

- (NSTimeInterval)timeWithSlider:(RasSliderControl *)slider
{
	return [self ratioWithSlider:slider] * _duration;
}

- (void)drawRange
{
	UIGraphicsBeginImageContextWithOptions(self.imgViewRange.frame.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
//	CGContextSetLineWidth(context, 1);
//	CGContextSetLineCap(context, kCGLineCapRound);
//	[RGBA2COLOR(255, 255, 155, 0.5) set];
	[RGBA2COLOR(255, 255, 155, 0.3) setFill];
	
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

- (void)showStatusWithSlider:(RasSliderControl *)slider
{
	_lbStatus.center = slider.center;
	CGFloat sLeft = slider.frame.origin.x;
	CGFloat sRight = slider.frame.origin.x + slider.frame.size.width;
	
	// 试着放左边
	CGFloat lLeft = sLeft-4-_lbStatus.frame.size.width;
	CGFloat lRight = lLeft + _lbStatus.frame.size.width;
	if (lLeft >= _sx && lRight <= _ex)
	{
		[_lbStatus setFrameLeft:lLeft];
	}
	else
	{
		// 放右边
		[_lbStatus setFrameLeft:(sRight+4)];
	}
	
	NSTimeInterval t = [self timeWithSlider:slider];
	NSInteger m = t / 60;
	NSInteger s = (NSInteger)t % 60;
	_lbStatus.text = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)m, (long)s];
	
	if (_lbStatus.alpha < 1)
	{
		[UIView animateWithDuration:0.5 animations:^(){
			_lbStatus.alpha = 1;
		}];
	}
}

- (void)hideStatus
{
	if (_lbStatus.alpha > 0)
	{
		[UIView animateWithDuration:0.5 animations:^(){
			_lbStatus.alpha = 0;
		}];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_duration <= 0)
	{
		return;
	}
	
	UITouch *touch = [touches anyObject];
	_start = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_duration <= 0)
	{
		return;
	}
	
	UITouch *touch = [touches anyObject];
	
	CGPoint nowPoint = [touch locationInView:self];
	CGFloat offsetX = nowPoint.x - _start.x;
	CGFloat lmtLeft = _bottomLeftSlider.center.x;
	CGFloat lmtRight = _bottomRightSlider.center.x;
	
	if (nowPoint.x < lmtLeft || nowPoint.x > lmtRight)
	{
		return;
	}
	
	lmtLeft += offsetX;
	if (lmtLeft < _sx)
	{
		return;
	}
	lmtRight += offsetX;
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
	
	[self showStatusWithSlider:_bottomLeftSlider];
	
	[self drawRange];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_duration <= 0)
	{
		return;
	}
	
	[self hideStatus];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_duration <= 0)
	{
		return;
	}
	
	[self hideStatus];
}

#pragma mark RasSliderControlDelegate

- (void)onSliderMove:(RasSliderControl *)slider
{
	[self restraintWithSlider:slider];
	[self drawRange];
	[self showStatusWithSlider:slider];
}

- (void)onSliderMoveEnd:(RasSliderControl *)slider
{
	[self hideStatus];
}

@end
