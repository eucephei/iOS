//
//  CustomAlertView.m
//  CustomAlert
//
//  Created by Aaron Crabtree on 10/14/11.
//  Modified by ace on 29/6/12.
//  Copyright (c) 2011 Tap Dezign, LLC. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
	for (UIView *subview in self.subviews) { 
		// NSLog(@"subview class :%@",[subview class]); 	
        // NSLog(@"subview.tag %i",subview.tag); 
		
		if ([subview isMemberOfClass:[UIImageView class]]) { 
            // [subview removeFromSuperview]; also works
			subview.hidden = YES; 
		}
        
        //Point to UILabels To Change Text
		if ([subview isMemberOfClass:[UILabel class]]) { 
            //Cast From UIView to UILabel
			UILabel *label = (UILabel*)subview;	
			label.textColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
			label.shadowColor = [UIColor blackColor];
			label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		}
	}
}

- (void)drawRect:(CGRect)rect 
{
	// GET REFERENCE TO CURRENT GRAPHICS CONTEXT
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    // CREATE BASE SHAPE WITH ROUNDED CORNERS FROM BOUNDS
	CGRect activeBounds = self.bounds;
	CGFloat cornerRadius = 10.0f;	
	CGFloat inset = 6.5f;	
	CGFloat originX = activeBounds.origin.x + inset;
	CGFloat originY = activeBounds.origin.y + inset;
	CGFloat width = activeBounds.size.width - (inset*2.0f);
	CGFloat height = activeBounds.size.height - (inset*2.0f);
    
	CGRect bPathFrame = CGRectMake(originX, originY, width, height);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:bPathFrame cornerRadius:cornerRadius].CGPath;
	
	// CREATE BASE SHAPE WITH FILL AND SHADOW
	CGContextAddPath(context, path);
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 6.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
    CGContextDrawPath(context, kCGPathFill);
	
	// CLIP STATE
	CGContextSaveGState(context); //Save Context State Before Clipping To "path"
	CGContextAddPath(context, path);
	CGContextClip(context);
	
	// DRAW GRADIENT
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	size_t count = 3;
	CGFloat locations[3] = {0.0f, 0.57f, 1.0f}; 
	CGFloat components[12] = 
	{	70.0f/255.0f, 70.0f/255.0f, 70.0f/255.0f, 1.0f,     //1
		55.0f/255.0f, 55.0f/255.0f, 55.0f/255.0f, 1.0f,     //2
		40.0f/255.0f, 40.0f/255.0f, 40.0f/255.0f, 1.0f};	//3
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    
	CGPoint startPoint = CGPointMake(activeBounds.size.width * 0.5f, 0.0f);
	CGPoint endPoint = CGPointMake(activeBounds.size.width * 0.5f, activeBounds.size.height);
    
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
	
	// HATCHED BACKGROUND
    
    // Offset buttonOffset by half point for crisp lines
    CGFloat buttonOffset = activeBounds.size.height - 66.5f;
    
    // Save Context State Before Clipping "hatchPath"
    CGContextSaveGState(context); 
	CGRect hatchFrame = CGRectMake(0.0f, buttonOffset, activeBounds.size.width, (activeBounds.size.height - buttonOffset+1.0f));
	CGContextClipToRect(context, hatchFrame);
	
	CGFloat spacer = 4.0f;
	int rows = (activeBounds.size.width + activeBounds.size.height/spacer);
	CGFloat padding = 0.0f;
	CGMutablePathRef hatchPath = CGPathCreateMutable();
	for(int i=1; i<=rows; i++) {
		CGPathMoveToPoint(hatchPath, NULL, spacer * i, padding);
		CGPathAddLineToPoint(hatchPath, NULL, padding, spacer * i);
	}
	CGContextAddPath(context, hatchPath);
	CGPathRelease(hatchPath);
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.15f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
    
    // Restore Last Context State Before Clipping "hatchPath"
	CGContextRestoreGState(context); 	
    
	//DRAW LINE
	CGMutablePathRef linePath = CGPathCreateMutable(); 
	CGFloat linePathY = (buttonOffset - 1.0f);
	CGPathMoveToPoint(linePath, NULL, 0.0f, linePathY);
	CGPathAddLineToPoint(linePath, NULL, activeBounds.size.width, linePathY);
	CGContextAddPath(context, linePath);
	CGPathRelease(linePath);
	CGContextSetLineWidth(context, 1.0f);
    
    // Save Context State Before Drawing "linePath" Shadow
	CGContextSaveGState(context); 
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.6f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 0.0f, [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.2f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
    
    // Restore Context State After Drawing "linePath" Shadow
	CGContextRestoreGState(context); 	
    
	// STROKE PATH FOR INNER SHADOW
	CGContextAddPath(context, path);
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 6.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
    
	// STROKE PATH TO COVER UP PIXILATION ON CORNERS FROM CLIPPING
    
    //Restore First Context State Before Clipping "path"
    CGContextRestoreGState(context); 
	CGContextAddPath(context, path);
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f].CGColor);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 0.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.1f].CGColor);
	CGContextDrawPath(context, kCGPathStroke);
	
}

@end

