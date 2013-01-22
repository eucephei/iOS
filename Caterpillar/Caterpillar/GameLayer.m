//
//  GameLayer.m
//  Caterpillar
//
//  Created by Apple User on 1/17/13.
//
//

#import "GameLayer.h"
#import "Sprout.h"
#import "Player.h"
#import "Caterpillar.h"
#import "Missile.h"
#import "Segment.h"
#import "NSArray+Reverse.h"

@interface GameLayer(Private)
- (CGPoint)randomEmptyLocation;
- (void)placeRandomSprout;
- (void)createSproutAtPostion:(CGPoint)position;
@end

@implementation GameLayer

@synthesize spritesBatchNode = _spritesBatchNode;
@synthesize sprouts = _sprouts;
@synthesize level = _level;
@synthesize player = _player;
@synthesize livesSprites = _livesSprites;
@synthesize playerScoreLabel = _playerScoreLabel;
@synthesize caterpillars = _caterpillars;
@synthesize missilesFiring = _missilesFiring;
@synthesize missilesWaiting = _missilesWaiting;

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    [scene addChild: layer];
    
    return scene;
}

- (void) dealloc
{
    [_spritesBatchNode release];
    [_sprouts release];
    [_player release];
    [_livesSprites release];
    [_caterpillars release];
    [_missilesWaiting release];
    [_missilesFiring release];
    [super dealloc];
}

-(id) init
{
    if( (self=[super init])) {
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
        
        //  initialize CCSpriteBatchNode object w/ caterpillar.png
        self.spritesBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"caterpillar.png"];
        [self addChild:self.spritesBatchNode];
        
        // add all of the sprites to Cocos2D’s CCSpriteFrameCache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"caterpillar.plist"];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        
        // fetch sprites out of the cache
        CCSprite * background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0,0);
        [self.spritesBatchNode addChild:background];
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        // start the game at level 1
        self.level = 1;
        
        // initialize all _locations
        for(int i = 0; i < kRows; i++) {
            for(int j = 0; j < kColumns; j++) {
                _locations[i][j] = NO;
            }
        }
        
        // place random sprouts on the grid
        srand(time(NULL));
        _sprouts = [[NSMutableArray alloc] init];
        for(int i = 0; i < kStartingSproutsCount; i++) {
            // 4
            [self placeRandomSprout];
        }
        
        _player = [[Player alloc] initWithGameLayer:self];
        _player.position = ccp(kGameAreaStartX + (kGameAreaWidth / 2), 88);
        _player.lives = kPlayerStartingLives;
        _player.score = 0;
        
        // init live sprites
        _livesSprites = [[NSMutableArray alloc] init];
        
        // Register for lives notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLives:)
                                                     name:kNotificationPlayerLives
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerLives
                                                            object:nil];
        
        
        _playerScoreLabel = [[CCLabelTTF labelWithString:@"0"
                                              dimensions:CGSizeMake(100, 25)
                                               alignment:NSTextAlignmentRight
                                                fontName:@"Helvetica"
                                                fontSize:18] retain];
        _playerScoreLabel.position = ccp(254,435);
        [self addChild:_playerScoreLabel];
        
        // Register for score notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateScore:)
                                                     name:kNotificationPlayerScore
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerScore
                                                            object:nil];
        
        _caterpillars = [[NSMutableArray alloc] init];
        CGPoint startingPosition = ccp(kGameAreaStartX, kGameAreaHeight + kGameAreaStartY - kGridCellSize / 2);
        Caterpillar *caterpillar = [[[Caterpillar alloc] initWithGameLayer:self level:self.level position:startingPosition] autorelease];
        [self.caterpillars addObject:caterpillar];
        
        [self schedule:@selector(update:)];
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        // Initialize each of the missile arrays
        _missilesWaiting = [[NSMutableArray alloc] initWithCapacity:kMissilesTotal];
        _missilesFiring = [[NSMutableArray alloc] initWithCapacity:kMissilesTotal];
        
        //  add new Missile objects to the missilesWaiting array
        for(int x = 0; x < kMissilesTotal; x++) {
            Missile *missile = [[Missile alloc] initWithGameLayer:self];
            [self.missilesWaiting addObject:missile];
            [missile release];
            
        }
        
    }
    return self;
}

// frequency at which the missiles are fired.
static float missleFireCount = 0;

- (void)update:(ccTime)dt
{
    [self.caterpillars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Caterpillar *caterpillar = (Caterpillar *)obj;
        [caterpillar update:dt];
    }];
    
    // Calculates the missile fire frequency
    float frequency = kMinMissileFrequency;
    if(kMissileFrequency / (self.level * 1.25) > kMinMissileFrequency) {
        frequency = kMissileFrequency / self.level;
    }
    
    // Release missile if the current frequency >= frequency for the level
    if(missleFireCount < frequency) {
        missleFireCount += dt;
    } else {
        missleFireCount = 0;
        
        // Pulls a missile out of the waiting array,
        // add the missile’s sprite to the batch node to be drawn
        if([self.missilesWaiting count] > 0) {
            Missile *missile = [self.missilesWaiting objectAtIndex:0];
            [self.missilesFiring addObject:missile];
            [self.missilesWaiting removeObjectAtIndex:0];
            missile.position = self.player.position;
            [self.spritesBatchNode addChild:missile.sprite];
            
        }
    }
    
    // Enumerates all of the missiles checking for dirty one
    __block Missile *dirty = nil;
    [self.missilesFiring enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Missile *missile = (Missile *)obj;
        [missile update:dt];
        if(missile.dirty) {
            dirty = missile;
            *stop = YES;
        }
    }];
    
    // Move dirty missile from the waiting to the firing array
    if(dirty) {
        dirty.dirty = NO;
        [self.missilesWaiting addObject:dirty];
        [self.missilesFiring removeObject:dirty];
        [self.spritesBatchNode removeChild:dirty.sprite cleanup:NO];
    }
    
    // enumerate each of the sprouts clears a dead one per iteration
    __block Sprout *deadSprout = nil;
    [self.sprouts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Sprout *sprout = (Sprout *)obj;
        if(sprout.lives == 0) {
            deadSprout = sprout;
            *stop = YES;
        }
    }];
    
    // remove dead sprout's sprite from the batch node
    if(deadSprout) {
        [self.spritesBatchNode removeChild:deadSprout.sprite cleanup:YES];
        [self.sprouts removeObject:deadSprout];
    }
    
}


- (void)placeRandomSprout
{
    // initializing a new Sprout object
    Sprout *sprout = [[[Sprout alloc] initWithGameLayer:self] autorelease];
    
    // random x within the grass area
    CGPoint p = [self randomEmptyLocation];
    
    // map this sprout from grid space to world space
    sprout.position = ccp(p.x * kGridCellSize + kGameAreaStartX,
                          (kGameAreaStartY - kGridCellSize + kGameAreaHeight) - p.y * kGridCellSize - kGridCellSize/2);
    
    // Sprout object gets added to the array of live sprouts
    [self.sprouts addObject:sprout];
}

- (CGPoint) randomEmptyLocation
{
    int column;
    int row;
    BOOL found = NO;
    
    // until an empty location is found
    while(!found) {
        // pick a random row and column
        column = (arc4random() % kColumns);
        row = (arc4random() % kRows);
        
        // check if a sprout exists at that location
        if(!_locations[row][column]) {
            found = YES;
            _locations[row][column] = YES;
        }
    }
    
    // return the new point that was created
    return CGPointMake(column, row);
}

- (void) updateLives:(NSNotification *) notification
{
    NSInteger lifeCount = self.player.lives;
    
    // clear out the livesSprites array
    [self.livesSprites enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.spritesBatchNode removeChild:obj cleanup:YES];
    }];
    [self.livesSprites removeAllObjects];
    
    // based on the player's remaining lives, add a new sprite to the scene
    for(int i = 0; i < lifeCount; i++) {
        CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"player.png"];
        sprite.position = ccp(kGameAreaStartX + (i * kGridCellSize * 2), 435);
        [self.livesSprites addObject:sprite];
        [self.spritesBatchNode addChild:sprite];
    }
    
}

- (void) updateScore:(NSNotification *) notification
{
    [self.playerScoreLabel setString:[NSString stringWithFormat:@"%d",self.player.score]];
}

// let the caller know that we are responding to touches
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

// when the player drags their finger on the device...
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // coordinates of the current/previous touch location
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    // change from the old location to the new one
    int xChange = touchLocation.x - oldTouchLocation.x;
    int yChange = touchLocation.y - oldTouchLocation.y;
    
    int newX = self.player.position.x + xChange;
    int newY = self.player.position.y + yChange;
    
    // ensure that the player stays within the “player area”
    if(newX < kGameAreaStartX + kGameAreaWidth - kGridCellSize &&
       newX > kGameAreaStartX &&
       newY > kGameAreaStartY + kGridCellSize / 2 &&
       newY < kGameAreaStartY + (kGridCellSize * 3)) {
        
        __block BOOL collide = NO;
        CGPoint oldPosition = self.player.position;
        
        // Update the player’s position
        self.player.position = ccp(newX,newY);
        
        // see if the player collides with any of the sprouts
        [self.sprouts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Sprout *sprout = (Sprout *)obj;
            CGRect sproutRect = [sprout getBounds];
            CGRect playerRect = [self.player getBounds];
            
            if(CGRectIntersectsRect(sproutRect, playerRect)) {
                collide = YES;
                *stop = YES;
            }
            
        }];
        
        // if there is a collision, revert the player’s position
        if(collide) {
            self.player.position = oldPosition;
        }
    }
}

- (void)checkNextLevel
{
    // Check to see if there are any caterpillars left
    if([self.caterpillars count] == 0) {
        
        // add scoring when the player advances in level
        self.player.score += kNextLevelPoints * self.level;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerScore object:nil];
        
        // Increment the level
        self.level++;
        
        // Create a new caterpillar and add it to the game
        CGPoint startingPosition = ccp(kGameAreaStartX, kGameAreaHeight + kGameAreaStartY - kGridCellSize / 2);
        Caterpillar *caterpillar = [[[Caterpillar alloc] initWithGameLayer:self level:self.level position:startingPosition] autorelease];
        [self.caterpillars addObject:caterpillar];
        
        // Add sprouts to match the minSproutCount
        int minSproutCount = kStartingSproutsCount + self.level * 2;
        
        if([self.sprouts count] < minSproutCount) {
            int numberOfSproutsToPlace = minSproutCount - [self.sprouts count];
            for(int x = 0; x < numberOfSproutsToPlace; x++) {
                [self placeRandomSprout];
            }
        }
        
    }
}

- (void)createSproutAtPostion:(CGPoint)position
{
    // Translates screen coordinates to grid coordinates
	int x = (position.x - kGameAreaStartX) / kGridCellSize;
	int y = (kGameAreaStartY - kGridCellSize + kGameAreaHeight + kGridCellSize/2 - position.y) / kGridCellSize;
	
	// Create a new sprout and add it to the game.
	Sprout *sprout = [[Sprout alloc] initWithGameLayer:self];
	sprout.position = position;
	[self.sprouts addObject:sprout];
	_locations[x][y] = YES;
}

- (void)splitCaterpillar:(Caterpillar *)caterpillar atSegment:(Segment *)segment
{
	// if hit a single segment caterpillar, 
	if([caterpillar.segments count] == 1) {
	    [self.spritesBatchNode removeChild:segment.sprite cleanup:NO];
	    [self.caterpillars removeObject:caterpillar];
	    [self createSproutAtPostion:segment.position];
        [self checkNextLevel];
	    return;
	}
	
	// remove the sprite of the segment hit from the batch node.
	[self.spritesBatchNode removeChild:segment.sprite cleanup:NO];
	
	// convert the hit segment to a sprout 
	[self createSproutAtPostion:segment.position];
	
	// split the caterpillar into two arrays, head/tail
	NSInteger indexOfSegement = [caterpillar.segments indexOfObject:segment];
	NSMutableArray *headSegments = [NSMutableArray array];
	NSMutableArray *tailsSegments = [NSMutableArray array];
	
	// where the other segments fall 
	[caterpillar.segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
	    if(idx < indexOfSegement) {
            [headSegments addObject:obj];
	    } else if(idx > indexOfSegement) {
            [tailsSegments addObject:obj];
	    }
	}];
    
	// check if there are any tail segments
	if([tailsSegments count] > 0) {
	    
	    // reverse the tail segments array
	    [tailsSegments reverse];
	    
	    // create new caterpillar object using the tail section
	    Caterpillar *newCaterpillar = [[[Caterpillar alloc] initWithGameLayer:self segments:tailsSegments level:self.level] autorelease];
	    newCaterpillar.position = [[tailsSegments objectAtIndex:0] position];
	    
	    // determine the current directions of the caterpillar that was hit
	    if(caterpillar.currentState == CSRight ||
	       caterpillar.previousState == CSRight) {
            // Was heading right
            if(caterpillar.currentState == CSDownLeft ||
               caterpillar.currentState == CSDownRight) {
                // Is heading down
                newCaterpillar.previousState = CSUpRight;
            } else {
                // Is heading up
                newCaterpillar.previousState = CSDownRight;
            }
            newCaterpillar.currentState = CSLeft;
	    } else {
            // Was heading left
            if(caterpillar.currentState == CSDownLeft ||
               caterpillar.currentState == CSDownRight) {
                // Is heading down
                newCaterpillar.previousState = CSUpRight;
            } else {
                // Is heading up
                newCaterpillar.previousState = CSDownRight;
            }
            newCaterpillar.currentState = CSRight;
	    }
	    
	    [self.caterpillars addObject:newCaterpillar];
	}
	
	// If there is still a head left, set the caterpillar that was hit’s segments to the remaining head segments.
	if([headSegments count] > 0) {
	    caterpillar.segments = headSegments;
	} else {
	    [self.caterpillars removeObject:caterpillar];
	}	
}

@end
