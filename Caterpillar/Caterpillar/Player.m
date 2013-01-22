//
//  Player.m
//  Caterpillar
//
//  Created by Apple User on 1/20/13.
//
//

#import "Player.h"
#import "GameLayer.h"

@implementation Player

@synthesize score = _score;
@synthesize lives = _lives;

- (id)initWithGameLayer:(GameLayer *)layer
{
    if(self = [super initWithGameLayer:layer]) {
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"player.png"];
        [self.gameLayer.spritesBatchNode addChild:self.sprite];
    }
    return self;
}


@end
