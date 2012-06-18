//
//  PhotosTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "PhotoScrollViewController.h"
#import "MapViewController.h"
#import "FlickrService.h"
#import "FlickrRecentPhotos.h"
#import "FlickrImage.h"
#import "FlickrPhotoAnnotation.h"

@interface PhotosTableViewController() <MapViewControllerDelegate>
@property (nonatomic, strong) UIImage *thumbnail;
@end

@implementation PhotosTableViewController

@synthesize flickrPhotos = _flickrPhotos;
@synthesize thumbnail = _thumbnail;

#pragma mark - Accessors

-(UIImage*) thumbnail
{
    if (!_thumbnail) 
        _thumbnail = [UIImage imageNamed:@"thumbnail.png"];
    
    return _thumbnail;
}

#pragma mark - MapViewControllerDelegate

-(NSArray*) mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.flickrPhotos count]];
    for (NSDictionary *photo in self.flickrPhotos) {
        // NSLog(@"photo dict = %@", photo);
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

-(void) refreshMapWithAnnotations:(NSArray*)annotations
{
    // MapViewController as detail view controller in iPad
}    

-(BOOL) annotationHasThumbnail
{
    return YES;
}

-(void) showPhotoForAnnotation:(id <MKAnnotation>)annotation
{
    if (self.splitViewController) {
        // iPAD
        PhotoScrollViewController *photoSVC = [self.splitViewController.viewControllers lastObject];
        if (photoSVC) 
            [photoSVC refreshPhotoScrollView:((FlickrPhotoAnnotation*)annotation).photo];
    } else {
        // iPHONE
        [self performSegueWithIdentifier:@"ShowPhoto" sender:annotation];
    }
}

- (UIImage *)thumbnailForAnnotation:(id <MKAnnotation>)annotation
{
    NSDictionary *photo = ((FlickrPhotoAnnotation *) annotation).photo;
    NSData *data = [FlickrService dataWithContentsOfURLForPhoto:photo format:FlickrPhotoFormatSquare];

    return (!data) ? nil : [UIImage imageWithData:data];
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
        self.flickrPhotos = [FlickrRecentPhotos retrievePhotos];
        [self refreshMapWithAnnotations:self.mapAnnotations];
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
    
	// set the cell's image, title, subtitles    
    cell.imageView.image = [self thumbnail];
    cell.textLabel.text = [FlickrService titleForPhoto:selectFlickrPhoto];
    cell.detailTextLabel.text = [FlickrService subtitleForPhoto:selectFlickrPhoto];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSString* title = cell.textLabel.text;
        
        // UIImage* image = [UIImage imageWithData:[FlickrService dataWithContentsOfURLForPhoto:selectFlickrPhoto format:FlickrPhotoFormatSquare]];
        UIImage* image = [FlickrImage imageForPhoto:selectFlickrPhoto format:FlickrPhotoFormatSquare];

        /* ensure modify only imageView in the row that appeared as cells are reused,
           by comparing local cell title copied on stack and the fresh cell title */
        dispatch_async(dispatch_get_main_queue(), ^{
           if ([title isEqualToString:cell.textLabel.text])
               cell.imageView.image = image;
        });
    });
    
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
        return;
 
    // the detail view controller    
    PhotoScrollViewController *photoSVC = [[self.splitViewController viewControllers] lastObject];

    // Set up the model and synchronize it's views, else handle by the segue
	if (photoSVC) [photoSVC refreshPhotoScrollView:[self photoInfo]];    
}

#pragma mark - Segueing

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{	    
   if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
   
       [segue.destinationViewController setDelegate:self];  
       [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
    
    else if ([segue.destinationViewController isKindOfClass:[PhotoScrollViewController class]]) {
        
        if ([sender isKindOfClass:[UITableViewCell class]])
            [[segue destinationViewController] setPhoto:[self photoInfo]];
        else if ([sender isKindOfClass:[FlickrPhotoAnnotation class]])
            [[segue destinationViewController] setPhoto:((FlickrPhotoAnnotation*)sender).photo];
    }
}


@end
