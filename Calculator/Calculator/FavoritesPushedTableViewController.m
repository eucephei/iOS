//
//  FavoritesPushedTableViewController.m
//  Calculator
//
//  Created by ace on 22/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoritesPushedTableViewController.h"

@implementation FavoritesPushedTableViewController

@synthesize delegate = _delegate;

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id selProg = [self.programs objectAtIndex:indexPath.row];
    [self.delegate selectedProgram:selProg byTableViewController:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
