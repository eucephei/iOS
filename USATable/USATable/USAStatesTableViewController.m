//
//  USAStatesTableViewController.m
//  USATable
//
//  Created by ace on 12/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "USAStatesTableViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "USAStateDetailViewController.h"
#import "USAState.h"

@implementation USAStatesTableViewController

@synthesize states = _states;
@synthesize filteredStates;
@synthesize groupedStates;

- (void)dealloc
{
	self.states = nil;
	self.filteredStates = nil;
	self.groupedStates = nil;
	
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		self.title = @"States";
        
        // group states into alphabetical sections
		NSArray* states = [USAState sortedStates];
		self.groupedStates = [NSMutableDictionary dictionary];
		for ( USAState* state in states ) {
			NSNumber* section = [NSNumber numberWithInt:
                [[UILocalizedIndexedCollation currentCollation] 
                           sectionForObject:state 
                    collationStringSelector:@selector(name)]];
			NSMutableArray* array = [self.groupedStates objectForKey:section];
			if ( array == nil ) {
				array = [NSMutableArray array];
				[self.groupedStates setObject:array forKey:section];
			}
			[array addObject:state];
		}
		
        // sort grouped states in each section
		NSArray* sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]];
		NSArray* keys = [[self.groupedStates allKeys] sortedArrayUsingDescriptors:sortDescriptors];
		NSMutableArray* allStates = [NSMutableArray array];
		for ( id key in keys ) {
			NSArray* stateList = [self.groupedStates objectForKey:key];
			stateList = [[UILocalizedIndexedCollation currentCollation] 
                               sortedArrayFromArray:stateList 
                            collationStringSelector:@selector(name)];
            
			// replace unsorted list in groups with sorted list
			[self.groupedStates setValue:stateList forKey:key];
			
			// add sorted states to list of all states
			[allStates addObjectsFromArray:stateList];
		}
		
		self.states = allStates;
		self.tabBarItem.image = [UIImage imageNamed:@"usmap-48.png"];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	// hide the search bar if it's visible
    CGRect tableRect = self.tableView.frame;
	CGRect searchBarRect = self.searchDisplayController.searchBar.frame;
	if ( CGRectIntersectsRect( tableRect, searchBarRect ) ) {
		self.tableView.contentOffset = (CGPoint) { .x = 0, .y = CGRectGetMaxY(searchBarRect) };
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

- (NSArray*) tableView:(UITableView*)tableView statesForSection:(NSInteger)section 
{
	if ( tableView == self.searchDisplayController.searchResultsTableView ) {
		// searching
		return self.filteredStates;
	}
    
	NSNumber* collatedSection = [NSNumber numberWithInt:
        [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:section]];
	return [self.groupedStates objectForKey:collatedSection];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
    return (tableView == self.searchDisplayController.searchResultsTableView) 
        ? 1 
        : [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //	NSLog(@"%s : section=%i", __PRETTY_FUNCTION__, section);
    return (tableView == self.searchDisplayController.searchResultsTableView) 
        ? [self.filteredStates count]
        : [[self tableView:tableView statesForSection:section] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s : { section=%i, row=%i }", __PRETTY_FUNCTION__, indexPath.section, indexPath.row);
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		if ( tableView == self.searchDisplayController.searchResultsTableView ) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.imageView.layer.borderWidth = 1.0;
		cell.imageView.layer.borderColor = [[UIColor colorWithWhite:0.90 alpha:1.0] CGColor];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue; // default is blue
		
        UIView* view = [[UIView alloc] init];
        view.backgroundColor = [UIColor orangeColor];
        cell.selectedBackgroundView = view;
        [view release];
	}
	
	// Configure the cell...
	NSArray* stateList = [self tableView:tableView statesForSection:indexPath.section];
	NSDictionary* state = [stateList objectAtIndex:indexPath.row];
	cell.textLabel.text = [state valueForKey:@"name"];
	cell.detailTextLabel.text = [state valueForKey:@"capital"];
	cell.imageView.image = [UIImage imageWithContentsOfFile:[USAState pathForSmallImage:state]];
    
	return cell;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section 
{
    return ( tableView == self.searchDisplayController.searchResultsTableView )
        ? nil // searching
        : [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
}

- (NSArray*) sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return ( tableView == self.searchDisplayController.searchResultsTableView ) 
        ? nil // searching // bug in documentation example
        : [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray: 
            [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index 
{
	if ( tableView == self.searchDisplayController.searchResultsTableView ) {
		// searching
		return 0;
	}
	
	if ( title == UITableViewIndexSearch ) {
		CGRect searchBarFrame = self.searchDisplayController.searchBar.frame;
		[tableView scrollRectToVisible:searchBarFrame animated:YES];
		return NSNotFound;
	} 
	
	UILocalizedIndexedCollation *currentCollation = [UILocalizedIndexedCollation currentCollation];
    
	// shift down one to adjust for UITableViewIndexSearch
	return [currentCollation sectionForSectionIndexTitleAtIndex:index - 1];
}

#pragma mark - UITableViewDelegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSLog(@"%s : { section=%i, row=%i }", __PRETTY_FUNCTION__, indexPath.section, indexPath.row );
	return 35;
}

- (NSIndexPath*) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return ( indexPath.row % 2 ) ? nil : indexPath;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	USAState* state = [[self tableView:tableView statesForSection:indexPath.section] objectAtIndex:indexPath.row];
	USAStateDetailViewController* controller = [[USAStateDetailViewController alloc] initWithState:state];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSString* criterion = 
        ([scope isEqualToString:@"Name"]) ? @"name CONTAINS[c] %@" 
        : ([scope isEqualToString:@"Abbrev"]) ? @"abbreviation CONTAINS[c] %@" 
        : ([scope isEqualToString:@"Capital"]) ? @"capital CONTAINS[c] %@" 
        : @"(name CONTAINS[cd] %@) OR (abbreviation CONTAINS[cd] %@) OR (capital CONTAINS[cd] %@)";
    
    NSPredicate* predicate = [scope isEqualToString:@"All"] 
        ? [NSPredicate predicateWithFormat:criterion, searchText, searchText, searchText] 
        : [NSPredicate predicateWithFormat:criterion, searchText];
    
    self.filteredStates = [self.states filteredArrayUsingPredicate:predicate];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString 
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];

    // Return YES to cause the search result table view to be reloaded.
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];    
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
