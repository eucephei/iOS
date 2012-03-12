//
//  Bobble.m
//  Bobble
//
//  Created by ace on 25/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Bobble.h"
#import "DampenedHarmonic.h"

#define kFilteringFactor 0.2

@interface Bobble ()

@property (nonatomic, assign) DampenedHarmonic *xHarmonic;
@property (nonatomic, assign) DampenedHarmonic *yHarmonic;

 -(void)pollSprings;
 -(void)adjustSpringX:(float) xValue springY:(float) yValue;
 -(void) setHarmonicDecayTimer:(NSTimer *)t;
 -(NSTimer *)harmonicDecayTimer;

@end

@implementation Bobble

@synthesize xHarmonic;
@synthesize yHarmonic;
@synthesize xDisplacement;
@synthesize yDisplacement;

// Used to filter accelerometer input
float lastX = 0.0;
float lastY = 0.0;

// Used to adjust the sign of accelerometer input for orientation
float xAxisSign = 1.0;
float yAxisSign = 1.0;

DampenedHarmonic *xSpring, *ySpring; 
NSTimer *harmonicDecayTimer;

#pragma mark -
#pragma mark Lifecycle

- (id)init 
{
    self = [super init];
    if( self != nil )
    {
        xHarmonic =
        [[DampenedHarmonic alloc]initWithEnergy:2.5
                                     LossPerSec:3.0
                                    SpringConst:1.5
                                           Mass:2.0
                                       Position:5.0
                                       Velocity:0.0];
        yHarmonic =
        [[DampenedHarmonic alloc]initWithEnergy:2.5
                                     LossPerSec:3.0
                                    SpringConst:1.5
                                           Mass:2.0
                                       Position:5.0
                                       Velocity:0.0];
        xSpring = xHarmonic;
        ySpring = yHarmonic;
        
        // Become the delegate of the shared accelerometer
        [UIAccelerometer sharedAccelerometer].delegate = self;
    }
    
    return self;
}

- (void) dealloc 
{
    [xHarmonic release];
    [yHarmonic release];
    xHarmonic = nil;
    yHarmonic = nil;
    xSpring = nil;
    ySpring = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Orientation

- (void)adjustSpringsForOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationPortrait) {
        xSpring = xHarmonic;
        ySpring = yHarmonic;
    } else {
        xSpring = yHarmonic;
        ySpring = xHarmonic;
    }
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        xAxisSign = -1.0;
        yAxisSign = -1.0;
    } else {
        xAxisSign = 1.0;
        yAxisSign = 1.0;
    }
}

#pragma mark -
#pragma mark Spring adjustment and harmonic decay

-(void)pollSprings 
{    
    self.xDisplacement = [xHarmonic position];
    self.yDisplacement = [yHarmonic position];
}

- (void)adjustSpringX:(float) xValue springY:(float) yValue
{    
    xValue = (xValue > 1.0) ? 1.0 : (xValue < -1.0) ? -1.0 : xValue;
    [xSpring setMaxAmplitude:xValue * xAxisSign];
    
    yValue = (yValue > 1.0) ? 1.0 : (yValue < -1.0) ? -1.0 : yValue;
    [ySpring setMaxAmplitude:yValue * yAxisSign];
    
    [self setHarmonicDecayTimer:[NSTimer scheduledTimerWithTimeInterval:0.1
                                                                 target:self
                                                               selector:@selector(pollSprings)
                                                               userInfo:nil
                                                                repeats:YES]];
}

-(void) setHarmonicDecayTimer:(NSTimer *)t 
{
    if (t != harmonicDecayTimer) {
        [t retain];
        [harmonicDecayTimer invalidate];
        [harmonicDecayTimer release];
        harmonicDecayTimer = t;
    }
}

-(NSTimer *) harmonicDecayTimer 
{
    return harmonicDecayTimer;
}

#pragma mark -
#pragma mark UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)meter 
        didAccelerate:(UIAcceleration *)accel 
{    
    NSLog(@"%f, %f, %f", [accel x], [accel y], [accel z]);

    float x = accel.x - ((accel.x * kFilteringFactor) + (lastX * (1.0 -kFilteringFactor)));
    float y = accel.y - ((accel.y * kFilteringFactor) + (lastY * (1.0 - kFilteringFactor)));
    
    if (fabsf(x) > 0.2 || fabsf(y) > 0.2) {
        lastX = x;
        lastY = y;

        [self adjustSpringX:lastX springY:lastY];
    }
}

@end
