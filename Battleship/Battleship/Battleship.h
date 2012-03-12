//
//  Battleship.h
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Battleship : NSObject

@property (nonatomic,retain,readonly) NSArray* indexPaths;

- (id) initWithIndexPaths:(NSArray*)indexPaths;
- (BOOL) isAtIndexPath:(NSIndexPath*)indexPath;

@end
