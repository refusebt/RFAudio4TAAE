//
//  RasSliderControl.m
//  RFAudioStudio
//
//  Created by gouzhehua on 14-10-20.
//  Copyright (c) 2014年 TechAtk. All rights reserved.
//

#import "RasSliderControl.h"

@interface RasSliderControl ()
{

}
@property (nonatomic, assign) CGPoint start;

@end

@implementation RasSliderControl
@synthesize start = _start;
@synthesize lmtStartX = _lmtStartX;
@synthesize lmtEndX = _lmtEndX;
@synthesize lmtStartY = _lmtStartY;
@synthesize lmtEndY = _lmtEndY;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.backgroundColor = [UIColor redColor];
		_lmtStartX = 0;
		_lmtEndX = 0;
		_lmtStartY = 0;
		_lmtEndY = 0;
		
	}
	return self;
}

- (void)setLimtStartX:(CGFloat)sx endX:(CGFloat)ex startY:(CGFloat)sy endY:(CGFloat)ey
{
	_lmtStartX = sx;
	_lmtEndX = ex;
	_lmtStartY = sy;
	_lmtEndY = ey;
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
	
	float offsetX = nowPoint.x - _start.x;
	float offsetY = nowPoint.y - _start.y;
	
	CGPoint next = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
	
	if (next.x < _lmtStartX)
	{
		next.x = _lmtStartX;
	}
	else if (next.x > _lmtEndX)
	{
		next.x = _lmtEndX;
	}
	
	if (next.y < _lmtStartY)
	{
		next.y = _lmtStartY;
	}
	else if (next.y > _lmtEndY)
	{
		next.y = _lmtEndY;
	}
	
	self.center = next;
}

@end
