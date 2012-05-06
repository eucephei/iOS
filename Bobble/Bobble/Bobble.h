//
//  Bobble.h
//  Bobble
//
//  Created by ace on 25/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DampenedHarmonic.h"

@interface Bobble : NSObject  <UIAccelerometerDelegate> {
    DampenedHarmonic *xHarmonic;
    DampenedHarmonic *yHarmonic;
}

@property (nonatomic,assign) float xDisplacement;
@property (nonatomic,assign) float yDisplacement;

- (void)adjustSpringsForOrientation:(UIInterfaceOrientation)orientation;

@end
