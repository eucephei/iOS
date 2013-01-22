//
//  Missile.m
//  Caterpillar
//
//  Created by Apple User on 1/22/13.
//
//

#import "Missile.h"
#import "GameLayer.h"
#import "GameConfig.h"
#import "Sprout.h"
#import "Caterpillar.h"
#import "Segment.h"
#import "Player.h"
#import "SimpleAudioEngine.h"

@implementation Missile

@synthesize dirty = _dirty;

// create the Missile’s sprite.
- (id)initWithGameLayer:(GameLayer *)layer
{
    
    if(self == [super initWithGameLayer:layer]) {
        self.sprite = [CCSprite spriteWithSpriteFrameName:@"missile.png"];
    }
    
    return self;
}

- (void)update:(ccTime)dt
{
    // how fast the missile will be moving
    int inc = kMissileSpeed * (self.gameLayer.level + 1.5);
    
    // prevent missile over-speeding
    if(inc > kMissileMaxSpeed) {
        inc = kMissileMaxSpeed;
    }
    
    // move the missile forward
    int y = self.position.y + inc;
    self.position = ccp(self.position.x,y);
    
    // if the missile collides ontop, garbage collect the dirty missiles 
    if(self.position.y > kGameAreaStartY + kGameAreaHeight) {
        self.dirty = YES;
    }

    // missile collision with the sprouts
    CGRect missileRect = [self getBounds];
    [self.gameLayer.sprouts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        Sprout *sprout = (Sprout *)obj;
        CGRect sproutRect = [sprout getBounds];
        if(CGRectIntersectsRect(missileRect, sproutRect)) {
            self.dirty = YES;
            sprout.lives--;
            
            self.gameLayer.player.score += kSproutHitPoints +
            (arc4random() % self.gameLayer.level) *
            (arc4random() % self.gameLayer.level);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerScore object:nil];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"sprout-hit.caf"];
        }
    }];
    
    __block Caterpillar *hitCaterpillar = nil;
    __block Segment *hitSegment = nil;
    
    // Enumerate all of the caterpillars in play
    [self.gameLayer.caterpillars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Caterpillar *caterpillar = (Caterpillar *)obj;
        [caterpillar.segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Segment *segment = (Segment *)obj;
            CGRect segmentRect = [segment getBounds];
            
            // Check for a collision and remember segment caterpillar hit
            if(CGRectIntersectsRect(missileRect, segmentRect)) {
                self.dirty = YES;
                hitCaterpillar = [caterpillar retain];
                hitSegment = [segment retain];
                *stop = YES;
            }
        }];
    }];
    
    // If a hit, we split the caterpillar at the current segment.
    if(hitCaterpillar && hitSegment) {
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"caterpillar-hit.caf"];
        
        // add scoring when the caterpillar is hit
        self.gameLayer.player.score += kCaterpillarHitPoints +
        (arc4random() % self.gameLayer.level) *
        (arc4random() % self.gameLayer.level);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerScore object:nil];
        
        [self.gameLayer splitCaterpillar:hitCaterpillar atSegment:hitSegment];
        [hitSegment release];
        [hitCaterpillar release];
    }

}

@end
