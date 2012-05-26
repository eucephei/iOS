//
//  CUTableViewController.h
//  Calculator
//
//  Created by ace on 22/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CUTableViewController : UITableViewController

@property (assign, nonatomic) NSArray * programs;

@end

@protocol FavoritesSelectionProtocol <NSObject>
@optional 
- (void)selectedProgram:(id)program byTableViewController:(UITableViewController *)sender;
@end
