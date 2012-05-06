//
//  BattleshipGrid.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattleshipGrid.h"
#import "Battleship.h"

static NSString *ROWS_KEY = @"rows";
static NSString *COLUMNS_KEY = @"columns";
static NSString *SHIPS_KEY = @"ships";

@interface BattleshipGrid ()
 @property (nonatomic,retain) NSMutableArray* ships;
@end

@implementation BattleshipGrid

@synthesize rows = _rows;
@synthesize columns = _columns;
@synthesize ships = _ships;

- (void) dealloc 
{
	[_ships release], _ships = nil;	
	[super dealloc];
}

- (id) initWithRows:(NSInteger)rows columns:(NSInteger)columns 
{
	self = [super init];
	if ( self != nil ) {
		_rows = rows;
		_columns = columns;		
		_ships = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) addShip:(Battleship*)ship 
{
	[self.ships addObject:ship];
}

- (BattleshipTurnResultType) resultForIndexPath:(NSIndexPath*)indexPath 
{
	NSInteger indexRow = [indexPath indexAtPosition:0];
	NSInteger indexColumn = [indexPath indexAtPosition:1];
	
	if ( indexRow >= self.rows || indexColumn >= self.columns ) {
		return BattleshipTurnResultInvalidIndexPath;
	}
	
	BattleshipTurn* turn = [[[BattleshipTurn alloc] initWithIndexPath:indexPath] autorelease];
	BattleshipTurnResultType result = BattleshipTurnResultMiss;
	for ( Battleship* ship in self.ships ) {
		NSInteger foundIndex = [ship.indexPaths indexOfObject:indexPath];
		if ( foundIndex != NSNotFound ) {
			result = BattleshipTurnResultHit;
			break;
		}
	}
	turn.result = result;

	return result;
}

#pragma mark - Keyed Archiving

- (void) encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeInteger:self.rows forKey:ROWS_KEY];
	[encoder encodeInteger:self.columns forKey:COLUMNS_KEY];
	[encoder encodeObject:self.ships forKey:SHIPS_KEY];
}

- (id) initWithCoder:(NSCoder *)decoder 
{
	self = [super init];
	if (self) {
		_rows = [decoder decodeIntegerForKey:ROWS_KEY];
		_columns = [decoder decodeIntegerForKey:COLUMNS_KEY];
		self.ships = [decoder decodeObjectForKey:SHIPS_KEY];
	}
	return self;
}

#pragma mark - Class Methods

+ (NSString*) labelForIndexPath:(NSIndexPath*)indexPath 
{
	NSString* label = [NSString stringWithFormat:@"%@%d", [@"ABCDEF" substringWithRange:NSMakeRange([indexPath indexAtPosition:0], 1)], [indexPath indexAtPosition:1] + 1, nil];
	return label;
}


@end
