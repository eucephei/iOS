//
//  Sprout.m
//  Caterpillar
//
//  Created by Apple User on 1/20/13.
//
//

#import "Sprout.h"
#import "GameConfig.h"

@implementation Sprout

@synthesize lives = _lives;

- (id) initWithGameLayer:(GameLayer *)layer
{
    // overwriting the initWithGameLayer method
	if(self = [super initWithGameLayer:layer]) {
        // sets up our current sprite to one of our CCSpriteBatchNode
	    self.sprite = [CCSprite spriteWithSpriteFrameName:@"sprout.png"];
        
	    // adds the sprite to the batch node layer
	    [self.gameLayer.spritesBatchNode addChild:self.sprite];
        
	    // set the number of lives of the sprout
	    self.lives = kSproutLives;
    }
    return self;
}

// 5
- (void)setLives:(NSInteger)lives
{
    _lives = lives;
    self.sprite.opacity = (_lives / 3.0) * 255;
}


@end
