//
//  Caterpillar.m
//  Caterpillar
//
//  Created by Apple User on 1/21/13.
//
//

#import "Caterpillar.h"
#import "GameLayer.h"
#import "GameConfig.h"
#import "Segment.h"
#import "Sprout.h"
#import "Player.h"
#import "SimpleAudioEngine.h"

@interface Caterpillar(Private)
- (void) collision;
@end

@implementation Caterpillar

@synthesize segments = _segments;
@synthesize currentState = _currentState;
@synthesize previousState = _previousState;
@synthesize totalTime = _totalTime;
@synthesize moveCount = _moveCount;
@synthesize level = _level;

- (void)dealloc
{
    [_segments release];
    [super dealloc];
}

- (id)initWithGameLayer:(GameLayer *)layer level:(NSInteger)level position:(CGPoint) position
{
    if(self = [super initWithGameLayer:layer]) {
        self.segments = [NSMutableArray array];
        self.level = level;
        self.currentState = CSRight;
        self.previousState = CSDownLeft;
        
        // prevent calling local setter method
        [super setPosition:position];
        
	    // caterpillar's length based on the current level
        int length = kCaterpillarLength + self.level / 2;
        
        for(int i = 0; i < length; i++) {
            // adding new segments to the segments array
            Segment *segment = [[[Segment alloc] initWithGameLayer:self.gameLayer] autorelease];
            segment.position = position;
            [self.segments addObject:segment];
        }
        
        __block Segment *parentSegment = [self.segments objectAtIndex:0];
        
        // segment gets enumerated and parent sets to the previous segment.
        [self.segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Segment *segment = (Segment *)obj;
            
            if(![segment isEqual:parentSegment]) {
                segment.parent = parentSegment;
            }
            
            segment.position = self.position;
            segment.previousPosition = self.position;
            parentSegment = segment;
            
        }];
    }
    
    return self;
}

- (id)initWithGameLayer:(GameLayer *)layer segments:(NSMutableArray *)segments  level:(NSInteger)level
{
    if(self = [super initWithGameLayer:layer]) {
        self.segments = segments;
        self.level = level;
        self.currentState = CSRight;
        self.previousState = CSDownLeft;
        
        // set the position of the rest of the segments
        __block int x = 0;
        __block Segment *parentSegment = [self.segments objectAtIndex:0];
        parentSegment.parent = nil;
        
        [self.segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Segment *segment = (Segment *)obj;
            
            if(x++ > 0) {
                if(![segment isEqual:parentSegment]) {
                    segment.parent = parentSegment;
                }
                parentSegment = segment;
            }
        }];
        
    }
    
    return self;
}


- (void)update:(ccTime)dt
{
    // limit how often this method is allowed to run based on the current level.
    self.totalTime += dt;
    if(self.totalTime < 4.0 / (self.level * 2.0)) {
        self.totalTime += dt;
        return;
    } else {
        self.totalTime = 0;
    }
    
	// localize the current caterpillar position
    __block int x = self.position.x;
    __block int y = self.position.y;
    
    // the bounds of the head segment
    CGRect caterpillarBounds = [self getBounds];
    
    // enumerate all of the sprout objects 
    [self.gameLayer.sprouts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Sprout *sprout = (Sprout *)obj;
        CGRect sproutBounds = [sprout getBounds];
        
        // if the caterpillar collided with a sprout on the right
        if(self.currentState == CSRight) {
            CGRect rightBounds = caterpillarBounds;
            rightBounds.origin.x = rightBounds.origin.x + kGridCellSize;
            if(CGRectIntersectsRect(rightBounds, sproutBounds)) {
                [self collision];
                *stop = YES;
            }
        }
        
        // if the caterpillar collided with a sprout on the left
        if(self.currentState == CSLeft) {
            CGRect leftBounds = caterpillarBounds;
            leftBounds.origin.x = leftBounds.origin.x - kGridCellSize;
            if(CGRectIntersectsRect(leftBounds, sproutBounds)) {
                [self collision];
                *stop = YES;
            }
        }
        
    }];
    
    // x += kGridCellSize; // just move the caterpillar to the right 
    switch (self.currentState) {
        case CSRight:
            
            // Check for a wall collision
            if(x + kGridCellSize >= kGameAreaStartX + kGameAreaWidth) {
                
                // Bottom collision
                if(y - kGridCellSize <= kGameAreaStartY) {
                    self.previousState = CSLeft;
                    self.currentState = CSRight;
                } else if(y >= kGameAreaStartY + kGameAreaHeight - kGridCellSize) {
                    
                    // Top collision
                    self.previousState = CSDownRight;
                    self.currentState = CSRight;
                } else {
                    
                    // Right wall collision
                    if(self.previousState == CSDownRight ||
                       self.previousState == CSDownLeft) {
                        self.currentState = CSDownLeft;
                    } else {
                        self.currentState = CSUpLeft;
                    }
                    self.previousState = CSRight;
                    [self update:4.0];
                    return;
                }
                
                // set up our next/previous positions
                [self collision];
                
            } else {
                // move the the caterpillar forward.
                x = x + kGridCellSize;
            }
            
            break;
        case CSLeft:
            
            // Check for a wall collision
            if(x <= kGameAreaStartX) {
                
                if(y - kGridCellSize <= kGameAreaStartY) {
                    self.previousState = CSRight;
                    self.currentState = CSLeft;
                } else if(y >= kGameAreaStartY + kGameAreaHeight) {
                    // Top collision
                    self.previousState = CSDownLeft;
                    self.currentState = CSLeft;
                } else {
                    // Left wall collision
                    if(self.previousState == CSDownRight ||
                       self.previousState == CSDownLeft) {
                        self.currentState = CSDownRight;
                    } else {
                        self.currentState = CSUpRight;
                    }
                    self.previousState = CSLeft;
                    [self update:4.0];
                    return;
                }
                
                [self collision];
            } else {
                x = x - kGridCellSize;
            }
            
            break;
        case CSDownLeft:
            //  0 causes the state to move down; 1 causes it to move forward.
            if(self.moveCount == 0) {
                y = y - kGridCellSize;
                self.moveCount++;
            } else {
                x = x - kGridCellSize;
                self.moveCount = 0;
                self.currentState = CSLeft;
                self.previousState = CSDownLeft;
            }
            
            break;
        case CSDownRight:
            if(self.moveCount == 0) {
                y = y - kGridCellSize;
                self.moveCount++;
            } else {
                x = x + kGridCellSize;
                self.moveCount = 0;
                self.currentState = CSRight;
                self.previousState = CSDownRight;
            }
            
            break;
        case CSUpRight:
            if(self.moveCount == 0) {
                y = y + kGridCellSize;
                self.moveCount++;
            } else {
                x = x + kGridCellSize;
                self.moveCount = 0;
                self.currentState = CSRight;
                self.previousState = CSUpRight;
            }
            
            break;
        case CSUpLeft:
            
            if(self.moveCount == 0) {
                y = y + kGridCellSize;
                self.moveCount++;
            } else {
                x = x - kGridCellSize;
                self.moveCount = 0;
                self.currentState = CSLeft;
                self.previousState = CSUpLeft;
            }
            
            break;
        default:
            break;
    }
    
    static int playerInvincibleCount = kPlayerInvincibleTime;
    static BOOL playerHit;
    CGRect playerRect = [self.gameLayer.player getBounds];
    
    // determine if segments collide with the player.
    [self.segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Segment *segment = (Segment *)obj;
        CGRect segmentRect = [segment getBounds];
        if(CGRectIntersectsRect(segmentRect, playerRect) && playerInvincibleCount == kPlayerInvincibleTime) {
            *stop = YES;
            playerHit = YES;
            
            // If the player was hit, decrement their lives and post the notification
            self.gameLayer.player.lives--;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerLives object:nil];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"player-hit.caf"];
        }
    }];
    
    // If the player was hit, check if they were still in the invincible period
    if(playerHit) {
        if(playerInvincibleCount > 0) {
            playerInvincibleCount--;
        } else {
            playerHit = NO;
            playerInvincibleCount = kPlayerInvincibleTime;
        }
    }
    
	// position of the caterpillar gets updated
    self.position = ccp(x,y);
    
}

- (void) collision
{
    // which direction the caterpillar is traveling
    BOOL down = self.currentState == CSDownLeft ||
    self.currentState == CSDownRight ||
    self.previousState == CSDownLeft ||
    self.previousState == CSDownRight;
    
    // set the previous state to the current state
    self.previousState = self.currentState;
    
    // in an Up Left/Right state or a Down Left/Right state
    if(down) {
        if(self.currentState == CSRight) {
            self.currentState = CSDownLeft;
        } else {
            self.currentState = CSDownRight;
        }
    } else {
        if(self.currentState == CSRight) {
            self.currentState = CSUpLeft;
        } else {
            self.currentState = CSUpRight;
        }
    }
}

- (void) setPosition:(CGPoint)position
{
    // everything gets updated properly in the parent
    [super setPosition:position];
    
    // moving the caterpillar basically means moving its head
    Segment *head = [self.segments objectAtIndex:0];
    head.position = position;
    
    // achieve the segments' “follow” behavior
    [self.segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Segment *segment = (Segment *)obj;
        if(segment.parent) {
            segment.position = segment.parent.previousPosition;
        }
    }];
}

@end
