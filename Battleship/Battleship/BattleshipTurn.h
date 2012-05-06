//
//  BattleshipTurn.h
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BattleshipTurn : NSObject

typedef enum {
	BattleshipTurnResultInvalidIndexPath = -1,
	BattleshipTurnResultMiss = 0,
	BattleshipTurnResultHit,
	BattleshipTurnResultAlreadyTried,
} BattleshipTurnResultType;

- (id) initWithIndexPath:(NSIndexPath*)indexPath;

@property (nonatomic,retain,readonly) NSIndexPath* indexPath;
@property (nonatomic,assign) BattleshipTurnResultType result;
@property (nonatomic,retain,readonly) NSDate* timestamp;


@end
