//
//  CUTableViewController.m
//  USATable
//
//  Created by ace on 12/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CUTableViewController.h"

@implementation CUTableViewController

@synthesize tableView = _tableView;
@synthesize clearsSelectionOnViewWillAppear;

- (void)dealloc
{
	self.tableView = nil;
	
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		self.clearsSelectionOnViewWillAppear = YES;
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
	self.tableView = nil;
	
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	if ( self.clearsSelectionOnViewWillAppear ) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
	}
}

- (void) viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
	[self.tableView flashScrollIndicators];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated 
{
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
	// TODO: handle a Done/Edit button
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"NEED TO IMPLEMENT %s", __PRETTY_FUNCTION__);
	return 1;
}

- (UITableViewCell*) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"NEED TO IMPLEMENT %s", __PRETTY_FUNCTION__);
	static NSString *CellIdentifier = @"Placeholder";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@ Placeholder Cell", NSStringFromClass([self class])];
	
	return cell;
}

@end
