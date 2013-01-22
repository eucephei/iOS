//
//  Caterpillar.h
//  Caterpillar
//
//  Created by Apple User on 1/21/13.
//
//

#import "cocos2d.h"
#import "GameObject.h"

@class Segment;


typedef enum {  // all of caterpillar's possible states 
    CSRight,
    CSLeft,
    CSUpLeft,
    CSUpRight,
    CSDownLeft,
    CSDownRight
} CaterpillarState;

@interface Caterpillar : GameObject

// caterpillar == array of Segment objects
@property (nonatomic, retain) NSMutableArray *segments;

@property (nonatomic, assign) CaterpillarState currentState;
@property (nonatomic, assign) CaterpillarState previousState;

@property (nonatomic, assign) ccTime totalTime; 
@property (nonatomic, assign) NSInteger moveCount;
@property (nonatomic, assign) NSInteger level;

- (id)initWithGameLayer:(GameLayer *)layer level:(NSInteger)level position:(CGPoint) position;
- (id)initWithGameLayer:(GameLayer *)layer segments:(NSMutableArray *)segments  level:(NSInteger)level;

- (void)update:(ccTime)dt; // caterpillar will be animated

@end
