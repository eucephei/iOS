//
//  VacationPhotosTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 30/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationPhotosTableViewController.h"
#import "VacationPhotoScrollViewController.h"
#import "Photo+Modify.h"

@implementation VacationPhotosTableViewController

@synthesize request = _request;
@synthesize documentContext = _documentContext;
@dynamic title; // iPhone only

#pragma mark - Accessors

-(void) refreshPhotos
{
    NSArray* photos = [self.documentContext executeFetchRequest:self.request error:nil];
    NSMutableArray *flickrPhotos = [[NSMutableArray alloc] initWithCapacity:photos.count];
    for (Photo* photo in photos) {
        [flickrPhotos addObject:photo.photoInfo];
    }
    self.flickrPhotos = flickrPhotos;   
    
    [self.tableView reloadData];
}

-(void) setRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    // request may be the same but results may not!
    self.request = request;
    
    // set context 
    self.documentContext = context;

    if (self.view.window) 
        [self refreshPhotos];
}

-(void) setTitle:(NSString *)title
{
    self.navigationItem.title = title;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // refresh list of photos from db 
    [self refreshPhotos];
}

#pragma mark - Segue (iPad only)

-(void) performSegueWithPhoto:(NSDictionary *)photo
{
    [super performSegueWithPhoto:photo];
    
    // iPAD: the detail view controller 
    id photoSVC = [[self.splitViewController viewControllers] lastObject];
    
    // Set up NSManagedObjectContext, else handle by the segue in iPhone
	if ([photoSVC respondsToSelector:@selector(setDocumentContext:)])
        [photoSVC setDocumentContext:self.documentContext]; 
}

#pragma mark - Segue 

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"ShowPhoto"])
        [segue.destinationViewController setDocumentContext:self.documentContext];
}

@end
