//
//  DampenedHarmonic.h
//  Bobble
//
//  Created by ace on 25/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DampenedHarmonic : NSObject {
    float storedEnergy;
    float energyLostPerSec;
    float qFactor;
    float dampingRatio;
    float springConstant;
    float mass;
    float frequency;
    float dampenedFrequency;
    float period;
    float maxAmplitude;
    float initialVelocity;
    NSDate *initialDate;
}

@property (nonatomic, assign) float period;
@property (nonatomic, assign) float maxAmplitude;
@property (nonatomic, retain) NSDate *initialDate;

- (DampenedHarmonic*)initWithEnergy:(float) energy
                         LossPerSec:(float) loss
                        SpringConst:(float) spring
                               Mass:(float) m
                           Position:(float) position
                           Velocity:(float) velocity;
- (float) position;
- (float) periods;

@end
