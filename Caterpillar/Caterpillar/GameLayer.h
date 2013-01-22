//
//  GameLayer.h
//  Caterpillar
//
//  Created by Apple User on 1/17/13.
//
//

#import "cocos2d.h"
#import "GameConfig.h"

@class Player;
@class Caterpillar;
@class Segment;

@interface GameLayer : CCLayer {
    BOOL _locations[kRows][kColumns]; // Sprouts locations on the grid
}

@property (nonatomic, retain) CCSpriteBatchNode *spritesBatchNode;
@property (nonatomic, retain) NSMutableArray *sprouts;
@property (nonatomic, assign) NSInteger level; // current game level
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSMutableArray *livesSprites;
@property (nonatomic, retain) CCLabelTTF *playerScoreLabel;
@property (nonatomic, retain) NSMutableArray *caterpillars;
@property (nonatomic, retain) NSMutableArray *missilesWaiting;
@property (nonatomic, retain) NSMutableArray *missilesFiring;

+ (CCScene *) scene;

- (void)splitCaterpillar:(Caterpillar *) caterpillar atSegment:(Segment *)segment;

@end
