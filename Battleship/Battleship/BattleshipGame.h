//
//  BattleshipGame.h
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "BattleshipTurn.h"

extern NSString* const BattleshipGameNewOpponentTurnNotification;
extern NSString* const BattleshipGameKeyNewOpponentTurn;

@class BattleshipGrid;

@interface BattleshipGame : NSObject

@property (nonatomic,retain,readonly) BattleshipGrid* grid;
@property (nonatomic,retain,readonly) NSMutableArray* playerTurns;
@property (nonatomic,retain,readonly) NSMutableArray* opponentTurns;
@property (nonatomic,assign) NSInteger playerHits;
@property (nonatomic,assign) NSInteger opponentHits;

- (id) initWithGrid:(BattleshipGrid*)grid;
- (BattleshipTurnResultType) fireOnIndexPath:(NSIndexPath*)indexPath;
- (void) startPeerPicker;
- (void) addOpponentTurn:(BattleshipTurn*)turn;

@end
