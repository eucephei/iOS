//
//  CUTableViewController.h
//  USATable
//
//  Created by ace on 12/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface CUTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL clearsSelectionOnViewWillAppear;

@end
