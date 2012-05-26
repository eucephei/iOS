//
//  FavoritesPopoverTableViewController.h
//  Calculator
//
//  Created by ace on 22/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CUTableViewController.h"

@interface FavoritesPopoverTableViewController : CUTableViewController

@property (assign, nonatomic) id<FavoritesSelectionProtocol> delegate;

@end

