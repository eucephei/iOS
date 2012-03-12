//
//  BattleshipViewMiss.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattleshipViewMiss.h"

@implementation BattleshipViewMiss

- (void)dealloc
{
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGRect circleRect = CGRectInset(self.bounds, 10.0, 10.0);
	UIBezierPath* path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
	path.lineWidth = 10;
	
	[[UIColor whiteColor] set];
	[path stroke];
}

@end
