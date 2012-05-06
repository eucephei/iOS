//
//  USAStatesTableViewController.h
//  USATable
//
//  Created by ace on 12/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CUTableViewController.h"

@interface USAStatesTableViewController : CUTableViewController 

@property (nonatomic,copy) NSArray* states;
@property (nonatomic,retain) NSArray* filteredStates;
@property (nonatomic,retain) NSMutableDictionary* groupedStates;

@end
