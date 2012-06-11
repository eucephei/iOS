//
//  PhotosTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "PhotosScrollViewController.h"
#import "FlickrService.h"

@implementation PhotosTableViewController

@synthesize flickrPhotos = _flickrPhotos;

#pragma mark - Setup

- (NSArray *)recentPhotos
{
	return [[[[NSUserDefaults standardUserDefaults] objectForKey:FLICKR_PHOTOS_RECENT] reverseObjectEnumerator] allObjects];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationItem.title isEqualToString:@"Recent Photos"]) {
        self.flickrPhotos = [self recentPhotos];
        [self.tableView reloadData];
    }
}

- (void) viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Description";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
	NSDictionary *selectFlickrPhoto = [self.flickrPhotos objectAtIndex:indexPath.row];

	// set the cell's title, subtitles    
    cell.textLabel.text = [FlickrService titleForPhoto:selectFlickrPhoto];
    cell.detailTextLabel.text = [FlickrService subtitleForPhoto:selectFlickrPhoto];
    
    return cell;
}

#pragma mark - Table view delegate

- (NSDictionary *) photoInfo  
{
    // photo at the currently selected row
    return [self.flickrPhotos objectAtIndex:self.tableView.indexPathForSelectedRow.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	    
	// the detail view controller
	PhotosScrollViewController *photosSVC = [[self.splitViewController viewControllers] lastObject];
    // Set up the model and synchronize it's views, else handle by the segue
	if (photosSVC) [photosSVC refreshPhotosScrollView:[self photoInfo]];
}

#pragma mark - Segueing

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{	
	[[segue destinationViewController] setPhoto:[self photoInfo]];
}


@end
