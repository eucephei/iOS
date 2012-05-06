//
//  USAStateDetailViewController.h
//  USATable
//
//  Created by ace on 12/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CUTableViewController.h"

@class USAState;

@interface USAStateDetailViewController : CUTableViewController

@property (nonatomic, retain) IBOutlet UIImageView *flagImageView;

- (id) initWithState:(USAState*)state;

@end
