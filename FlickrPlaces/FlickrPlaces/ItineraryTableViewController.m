//
//  ItineraryTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 30/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItineraryTableViewController.h"
#import "VacationPhotosTableViewController.h"
#import "Place+Create.h"
#import "Photo+Modify.h"
#import "FlickrService.h"

@implementation ItineraryTableViewController

@synthesize document = _document;

#pragma mark - Accessors

-(void) setDocument:(UIManagedDocument *)document
{
    if (_document != document) {
        _document = document;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[Place fetchRequestByDate] managedObjectContext:document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
}

-(void) popViewControllerIfNoItinerary
{
    if (!self.fetchedResultsController.fetchedObjects.count)
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.title = @"Itinerary";
    self.tableView.delegate = self;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self popViewControllerIfNoItinerary];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Itinerary Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    Place* place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [FlickrService titleFromPlace:place.name];
    cell.detailTextLabel.text = [FlickrService descriptionFromPlace:place.name];
    
    return cell;
}

#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id vc = segue.destinationViewController;
    if ([vc respondsToSelector:@selector(setRequest:inContext:)]) {
        
        Place* place = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        NSFetchRequest *request = [Photo fetchRequestforPlace:place];
        
        [vc setRequest:request inContext:self.document.managedObjectContext];
        [vc setTitle:[FlickrService titleFromPlace:place.name]];
    }
}


@end
