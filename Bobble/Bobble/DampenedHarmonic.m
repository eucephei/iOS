//
//  DampenedHarmonic.m
//  Bobble
//
//  Created by ace on 25/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DampenedHarmonic.h"
#import <math.h>

@implementation DampenedHarmonic

@synthesize period;
@synthesize maxAmplitude;
@synthesize initialDate;

- (DampenedHarmonic*)initWithEnergy:(float) energy
                         LossPerSec:(float) loss
                        SpringConst:(float) spring
                               Mass:(float) m
                           Position:(float) position
                           Velocity:(float) velocity 
{
    storedEnergy = energy;
    energyLostPerSec = loss;
    qFactor = 2 * M_PI * storedEnergy/energyLostPerSec;
    dampingRatio = 1/(2 * qFactor);
    springConstant = spring;
    mass = m;
    frequency = sqrt(springConstant/mass);
    dampenedFrequency = frequency * sqrtf(1 -(dampingRatio * dampingRatio));
    period = 2.0 * M_PI / dampenedFrequency;
    maxAmplitude = position;
    initialVelocity = velocity;
    [self setInitialDate:[NSDate date]];
    
    return self;
}

- (void) setMaxAmplitude:(float)position 
{
    maxAmplitude = position;
    [self setInitialDate:[NSDate date]];
}

- (float) position 
{
    float pos;
    
    NSLog(@"storedEnergy %f", storedEnergy);
    NSLog(@" energyLostPerSec %f", energyLostPerSec);
    NSLog(@"qFactor %f", qFactor);
    NSLog(@"dampingRatio %f", dampingRatio);
    NSLog(@"springConstant %f", springConstant);
    NSLog(@"mass %f", mass);
    NSLog(@"frequency %f", frequency);
    NSLog(@"dampenedFrequency %f", dampenedFrequency);
    NSLog(@"period %f", period);
    NSLog(@"initialVelocity %f", initialVelocity);
    
    NSTimeInterval t = [[self initialDate] timeIntervalSinceNow] * -10.0;
    pos = expf(-dampingRatio * frequency * t)
        * (maxAmplitude * cosf(dampenedFrequency * t))
        + (initialVelocity * cosf(dampenedFrequency * t));
    
    return pos;
}

- (float) periods 
{
    NSTimeInterval t = [[self initialDate] timeIntervalSinceNow] * -10.0;
    return t / period;
}


@end
