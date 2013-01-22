//
//  Segment.m
//  Caterpillar
//
//  Created by Apple User on 1/21/13.
//
//


#import "Segment.h"
#import "GameLayer.h"

@implementation Segment

@synthesize previousPosition = _previousPosition;
@synthesize parent = _parent;

- (id)initWithGameLayer:(GameLayer *)layer
{
    if(self = [super initWithGameLayer:layer]) {
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"segment.png"];
        [self.gameLayer.spritesBatchNode addChild:self.sprite];
    }
    return self;
}

- (void) setPosition:(CGPoint)position
{
    _previousPosition = self.position;
    [super setPosition:position];
}


@end
