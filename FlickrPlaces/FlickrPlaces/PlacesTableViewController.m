//
//  PlacesTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesTableViewController.h"
#import "PhotosTableViewController.h"
#import "MapViewController.h"
#import "FlickrService.h"
#import "FlickrPlaceAnnotation.h"

@interface PlacesTableViewController() <MapViewControllerDelegate>
// @property (nonatomic, strong, readonly) NSArray* mapAnnotations;
@end

@implementation PlacesTableViewController

@synthesize flickrPlaces = _flickrPlaces;
@synthesize selectedFlickrPlaces = _selectedFlickrPlaces;
@synthesize countries = _countries;
@synthesize refreshButton = _refreshButton;

#pragma mark - Target Action

- (IBAction)refresh:(id)sender {
    
    UIActivityIndicatorView* spinner = [UIActivityIndicatorView alloc];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        spinner = [spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    } else {
        spinner = [spinner initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.frame = self.tableView.frame;
        [self.tableView.superview insertSubview: spinner aboveSubview: self.tableView];
    }

    [spinner startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        self.flickrPlaces = [FlickrService topPlaces];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            self.selectedFlickrPlaces = [FlickrService selectTopPlaces:self.flickrPlaces];
            self.countries = [[self.selectedFlickrPlaces allKeys] sortedArrayUsingSelector: 
                              @selector(caseInsensitiveCompare:)];
            self.navigationItem.leftBarButtonItem = sender;
            [self.tableView reloadData];
        });
    });
}

#pragma mark - MapViewControllerDelegate

-(NSArray*) mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.flickrPlaces count]];
    for (NSString* country in self.countries) 
        for (NSDictionary *place in [self.selectedFlickrPlaces valueForKey:country])
            [annotations addObject:[FlickrPlaceAnnotation annotationForPlace:place]];
        
    return annotations;
}

-(BOOL) annotationHasThumbnail
{
    return NO;
}

-(void) showPhotoForAnnotation:(id <MKAnnotation>)annotation
{
    [self performSegueWithIdentifier:@"ShowPlacePhotos" sender:annotation];
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
    [self setRefreshButton:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh:self.navigationItem.leftBarButtonItem];
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
    // unhighlight row to prevent multiple rows selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue

- (NSDictionary *)aPlace:(int)place inCountry:(int)country
{
    return [[self.selectedFlickrPlaces valueForKey:[self.countries objectAtIndex:country]] objectAtIndex:place];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{	
    if ([segue.identifier isEqualToString:@"ShowMap"]) {
        
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
        [segue.destinationViewController setDelegate:self]; 
    } 
    
    else if ([segue.identifier isEqualToString:@"ShowPlacePhotos"]){
        
        NSDictionary *place;
    
        if  ([sender isKindOfClass:[UITableViewCell class]]) {
            int section = self.tableView.indexPathForSelectedRow.section;
            int row = self.tableView.indexPathForSelectedRow.row;
            place = [self aPlace:row inCountry:section];
        }
        else if ([sender isKindOfClass:[FlickrPlaceAnnotation class]]) 
            place = ((FlickrPlaceAnnotation *)sender).place;
         
        [segue.destinationViewController setFlickrPhotos:[FlickrService photosInPlace:place]];
        [segue.destinationViewController setTitle:[FlickrService titleForPlace:place]];
    } 
}

@end
