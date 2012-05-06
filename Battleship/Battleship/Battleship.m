//
//  Battleship.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Battleship.h"

static NSString *INDEX_PATHS_KEY = @"indexPaths";

@implementation Battleship

@synthesize indexPaths = _indexPaths;

- (void) dealloc 
{
	[_indexPaths release], _indexPaths = nil;
	[super dealloc];
}

- (id) initWithIndexPaths:(NSArray *)indexPaths 
{
	self = [super init];
	if ( self != nil ) {
		_indexPaths = [indexPaths copy];
	}
	return self;
}

- (BOOL) isAtIndexPath:(NSIndexPath*)indexPath 
{
	return [self.indexPaths indexOfObject:indexPath] != NSNotFound;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeObject:self.indexPaths forKey:INDEX_PATHS_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
	self = [super init];
	if (self) {
		_indexPaths = [[decoder decodeObjectForKey:INDEX_PATHS_KEY] retain];
	}
	return self;
}

@end
