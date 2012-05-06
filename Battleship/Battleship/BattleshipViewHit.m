//
//  BattleshipViewHit.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattleshipViewHit.h"

@implementation BattleshipViewHit

- (void)dealloc
{
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// Drawing code
	CGRect myRect = CGRectInset(self.bounds, 10.0, 10.0);
	UIBezierPath* path = [UIBezierPath bezierPath];
	[path moveToPoint:myRect.origin];
	[path addLineToPoint:(CGPoint){ .x = CGRectGetMaxX(myRect), .y = CGRectGetMaxY(myRect) }];
	
	[path moveToPoint:(CGPoint){ .x = CGRectGetMaxX(myRect), .y = CGRectGetMinY(myRect) }];
	[path addLineToPoint:(CGPoint){ .x = CGRectGetMinX(myRect), .y = CGRectGetMaxY(myRect) }];
	
	path.lineWidth = 10;
	[[UIColor redColor] set];
	[path stroke];
}

@end
