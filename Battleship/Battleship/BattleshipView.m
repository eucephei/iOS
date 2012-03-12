//
//  BattleshipView.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattleshipView.h"

@implementation BattleshipView

- (void)dealloc
{
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *)aDecoder 
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //	CGFloat ratio = CGRectGetWidth(self.bounds) / CGRectGetHeight(self.bounds);
    //	if ( ratio < 1 ) {
    //		ratio = CGRectGetHeight(self.bounds) / CGRectGetWidth(self.bounds);
    //	}
    //	CGFloat edge = 
    
    // Drawing code
	CGRect drawingRect = CGRectInset(self.bounds, 2, 2);
    //	CGFloat height = CGRectGetHeight(drawingRect);
    //	CGFloat width = CGRectGetWidth(drawingRect);
	UIBezierPath* path = [UIBezierPath bezierPath];
	CGPoint drawPoint = drawingRect.origin;
	[path moveToPoint:drawPoint];
	
	drawPoint.x = CGRectGetMaxX(self.bounds) - CGRectGetMaxY(self.bounds);
	[path addLineToPoint:drawPoint];
	
	CGPoint forePoint = { .x = CGRectGetMaxX(drawingRect), .y = CGRectGetMidY(drawingRect) };
	CGPoint controlPoint = {
		.x = drawPoint.x + ( forePoint.x - drawPoint.x ) * 0.7,
		.y = drawPoint.y + ( forePoint.y - drawPoint.y ) * 0.1,
	};
	[path addQuadCurveToPoint:forePoint controlPoint:controlPoint];
	
	drawPoint.y = CGRectGetMaxY(drawingRect);
	controlPoint.y = CGRectGetMaxY(self.bounds) - controlPoint.y;
	[path addQuadCurveToPoint:drawPoint controlPoint:controlPoint];
	
	drawPoint.x = CGRectGetMinX(drawingRect);
	[path addLineToPoint:drawPoint];
	[path closePath];
	
	[[UIColor grayColor] set];
	[path fill];
	
	[[UIColor blackColor] set];
	[path setLineWidth:2.0];
	[path stroke];
}

@end
