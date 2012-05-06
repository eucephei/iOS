//
//  BattleshipGridView.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattleshipGridView.h"

const CGFloat kGridSize = 50;

@implementation BattleshipGridView

- (void)dealloc
{
	[super dealloc];
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
	// Drawing code
	UIBezierPath* path = [[UIBezierPath alloc] init];

	CGFloat currentX = 0;
	while ( currentX <= CGRectGetWidth(self.bounds) ) {
		[path moveToPoint:(CGPoint){ .x = currentX, .y = 0 }];
		[path addLineToPoint:(CGPoint){ .x = currentX, .y = CGRectGetMaxY(rect) }];
		currentX += kGridSize;
	}
	
	CGFloat currentY = 0;
	while ( currentY <= CGRectGetMaxY(self.bounds) ) {
		[path moveToPoint:(CGPoint){ .x = 0, .y = currentY }];
		[path addLineToPoint:(CGPoint){ .x = CGRectGetMaxX(rect), .y = currentY }];
		currentY += kGridSize;
	}
	[[UIColor grayColor] set];
	[path stroke];
	[path release];    
}

// remove subViews class from this view
- (void)removeSubViewClass:(Class)subViewType  
{
    // Again, valid UIView *view:
    for(UIView *subview in [self subviews]) {
        if([subview isKindOfClass:subViewType]) {
            [subview removeFromSuperview];
        }
    }
}

@end
