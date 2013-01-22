//
//  GameObject.m
//  Caterpillar
//
//  Created by Apple User on 1/20/13.
//
//

#import "GameObject.h"


@implementation GameObject

@synthesize sprite = _sprite;
@synthesize gameLayer = _gameLayer;
@synthesize position = _position;


- (void)dealloc
{
    [_sprite release];
    [super dealloc];
}

- (id)initWithGameLayer:(GameLayer *)layer
{
    if(self = [super init]) {
        self.gameLayer = layer;
    }
    return self;
}

// ensure that the sprite gets moved on the screen
- (void) setPosition:(CGPoint)position
{
    _position = position;
    _sprite.position = position;
}

// determines the bounding box for our object
- (CGRect)getBounds
{
    CGSize size = [self.sprite contentSize];
    return CGRectMake(self.position.x - size.width * self.sprite.anchorPoint.x,
                      self.position.y - size.height * self.sprite.anchorPoint.y,
                      size.width, size.height);
}


@end
