//
//  BattleshipTurn.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattleshipTurn.h"

@interface BattleshipTurn ()
 @property (nonatomic,retain,readwrite) NSIndexPath* indexPath;
 @property (nonatomic,retain,readwrite) NSDate* timestamp;
@end

@implementation BattleshipTurn

@synthesize indexPath = _indexPath;
@synthesize result = _result;
@synthesize timestamp = _timestamp;

- (void) dealloc 
{
	[_indexPath release], _indexPath = nil;
	[_timestamp release], _timestamp = nil;
    
	[super dealloc];
}

- (id) initWithIndexPath:(NSIndexPath*)indexPath 
{
	self = [super init];
	if ( self != nil ) {
		_indexPath = [indexPath retain];
		_timestamp = [[NSDate date] retain];
	}
	return self;
}

@end
