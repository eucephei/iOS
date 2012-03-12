//
//  BattleshipGrid.h
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BattleshipTurn.h"

@class Battleship;

@interface BattleshipGrid : NSObject

@property (nonatomic,assign,readonly) NSInteger rows;
@property (nonatomic,assign,readonly) NSInteger columns;

- (id) initWithRows:(NSInteger)rows columns:(NSInteger)columns;
- (void) addShip:(Battleship*)ship;
- (BattleshipTurnResultType) resultForIndexPath:(NSIndexPath*)indexPath;
+ (NSString*) labelForIndexPath:(NSIndexPath*)indexPath;

@end
