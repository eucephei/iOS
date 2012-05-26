//
//  GraphView.m
//  Calculator
//
//  Created by ace on 21/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

#define DOT_RADIUS              1.0
#define DEFAULT_SCALE           15 
#define KEY_SCALE               @"scale"
#define KEY_ORIGIN_X            @"origin.x" 
#define KEY_ORIGIN_Y            @"origin.y" 

@implementation GraphView

@synthesize origin              = _origin;
@synthesize scale               = _scale;
@synthesize dataSource          = _dataSource;

#pragma mark -

- (void)setup
{  
    self.contentMode = UIViewContentModeRedraw;   // redraw if our bounds changes  
}

- (void)awakeFromNib    
{
    [self setup];   // initialize upon leaving storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

#pragma mark - Accessors

-(float)scale 
{
    if (!_scale) {
        _scale = [[NSUserDefaults standardUserDefaults] floatForKey:KEY_SCALE];
        if (!_scale) _scale = DEFAULT_SCALE;
    }
    return _scale;
}

-(void)setScale:(float)scale 
{
    if (_scale != scale) {
        _scale = scale;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:_scale forKey:KEY_SCALE];
        [prefs synchronize];
        
        [self setNeedsDisplay];
    }
}

-(CGPoint)origin 
{
    if (CGPointEqualToPoint(_origin, CGPointZero)) {
        _origin.x = [[NSUserDefaults standardUserDefaults] floatForKey:KEY_ORIGIN_X];
        _origin.y = [[NSUserDefaults standardUserDefaults] floatForKey:KEY_ORIGIN_Y];
        
        if (CGPointEqualToPoint(_origin, CGPointZero))
            _origin = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    return _origin;
}

-(void)setOrigin:(CGPoint)origin 
{
    if (!CGPointEqualToPoint(origin, _origin)) {
        _origin = origin;
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:_origin.x forKey:KEY_ORIGIN_X];
        [prefs setFloat:_origin.y forKey:KEY_ORIGIN_Y];
        [prefs synchronize];
        
        [self setNeedsDisplay];
    }
}

- (void)adjustOrigin:(CGPoint)offset
{
    _origin.x += offset.x;
    _origin.y += offset.y;
    [self setNeedsDisplay];
}

#pragma mark - GestureRecognizers

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // incremental, not cumulative future changes
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        [self adjustOrigin:translation];
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture 
{     
    if (gesture.state == UIGestureRecognizerStateEnded) {  
        CGPoint tapLocation = [gesture locationInView:self];
        self.origin = tapLocation;
    } 
}

#pragma mark - draw Graph

const CGFloat vermilionColorValues[] = {.83,.16,.23, 1.0};

- (void)drawDotAtPoint:(CGPoint)p inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextSetFillColor(context, vermilionColorValues);
    CGContextSetStrokeColor(context, vermilionColorValues);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, DOT_RADIUS, 0, 2*M_PI, YES); // 360 degrees (0 to 2π) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

- (void)drawLineFromPoint:(CGPoint)a toPoint:(CGPoint)b inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextSetStrokeColor(context, vermilionColorValues);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, a.x, a.y);
    CGContextAddLineToPoint(context, b.x, b.y);
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

// Figure out each pixel's "value", evaluate it, convert back to the coordinate system
//
// Loop over the X values of the currentPoint (x,y struct) and store the returned
// pixel value in the Y value of currentPoint.
- (void) plotGraph
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint currentPoint;                           // current loop and result
    CGPoint priorPoint = CGPointZero;               // prior point for drawing a line
    
	for (currentPoint.x = 0; currentPoint.x < self.bounds.size.width; currentPoint.x++) {
        CGContextBeginPath(context);
        double xValue = (currentPoint.x - self.origin.x) / self.scale;
        double yValue = [self.dataSource functionAtX:xValue];
        currentPoint.y = self.origin.y - (yValue * self.scale);
        
        if ([self.dataSource lineModeSwitchOn:self])
            [self drawLineFromPoint:priorPoint toPoint:currentPoint inContext:context];
        else 
            [self drawDotAtPoint:currentPoint inContext:context];
        
        priorPoint = currentPoint;    
    }
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithRed:0 green:.35 blue:1.02 alpha:1] setStroke];
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:self.origin
                         scale:self.scale];
    
    if ([self.dataSource validProgram]) 
        [self plotGraph];
}

@end
