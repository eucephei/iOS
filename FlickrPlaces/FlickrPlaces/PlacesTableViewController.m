//
//  PlacesTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "PhotosTableViewController.h"
#import "FlickrService.h"

@implementation PlacesTableViewController

@synthesize flickrPlaces = _flickrPlaces;
@synthesize selectedFlickrPlaces = _selectedFlickrPlaces;
@synthesize countries = _countries;


#pragma mark - Setup

- (void)loadTopPlacesByCountry
{	
	if (self.flickrPlaces) return;
    
    // load top places, selected place, countries
    
	self.flickrPlaces = [FlickrService loadTopPlaces];
	self.selectedFlickrPlaces = [FlickrService loadSelectPlaces:self.flickrPlaces];
	self.countries = [[self.selectedFlickrPlaces allKeys] sortedArrayUsingSelector: 
                           @selector(caseInsensitiveCompare:)];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTopPlacesByCountry];
    
    // preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(BOOL)wantsFullScreenLayout 
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.selectedFlickrPlaces objectForKey:[self.countries objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countries objectAtIndex:section];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	NSDictionary *place = [[self.selectedFlickrPlaces objectForKey:[self.countries objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	NSArray *selectFlickrPlace = [FlickrService titlesForPlace:place];
    
    // Format place info into the cell's title and subtitle
    cell.textLabel.text = [selectFlickrPlace objectAtIndex:0];
    cell.detailTextLabel.text = [selectFlickrPlace objectAtIndex:1];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    // unhighlight selected row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{	
    int section = self.tableView.indexPathForSelectedRow.section;
	int row = self.tableView.indexPathForSelectedRow.row;
	
    //NSLog(@"selected Flickr Place: %@", [self.flickrPlaces objectAtIndex:row]);  
    if ([segue.destinationViewController isKindOfClass:[PhotosTableViewController class]]){
        PhotosTableViewController *photosTVC = (PhotosTableViewController *)segue.destinationViewController;  
        
        NSDictionary *place = [[self.selectedFlickrPlaces valueForKey:[self.countries objectAtIndex:section]] objectAtIndex:row];

        photosTVC.flickrPhotos = [FlickrService photosInPlace:place];
        photosTVC.navigationItem.title = [[(UITableViewCell *)sender textLabel] text];
    }
}

@end
