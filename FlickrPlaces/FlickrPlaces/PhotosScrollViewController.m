//
//  PhotosScrollViewController.m
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosScrollViewController.h"
#import "FlickrService.h"

@implementation PhotosScrollViewController

@synthesize photo = _photo;
@synthesize imageView = _photoView;
@synthesize scrollView = _scrollView;

#pragma mark - Setup

- (void)synchronizeView 
{    
	self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
	
    self.imageView.image = [UIImage imageWithData:[FlickrService dataWithContentsOfURLForPhoto:self.photo]];
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    self.scrollView.zoomScale = 1;
	self.scrollView.contentSize = self.imageView.image.size;
}

- (void) storePhoto
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	NSMutableArray *recentPhotos = [[defaults objectForKey:FLICKR_PHOTOS_RECENT] mutableCopy];
	if (!recentPhotos) recentPhotos = [NSMutableArray array];
    
    // remove oldest photo if list too long
	if (recentPhotos.count > FLICKR_PHOTOS_MAX)  
		[recentPhotos removeObjectAtIndex:0];
	
    // remove old photo identifical to one just selected
	NSString *photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
	for (int i = 0; i < recentPhotos.count; i++) {
		NSDictionary *photo = [recentPhotos objectAtIndex:i];
		if ([[photo objectForKey:FLICKR_PHOTO_ID] isEqualToString:photoID]) {
			[recentPhotos removeObject:photo];
			continue;
		}        
	}

    // add selected photo
	[recentPhotos addObject:self.photo];

	[defaults setObject:recentPhotos forKey:FLICKR_PHOTOS_RECENT];
	[defaults synchronize];
}

- (void)updateZoomScale
{	
	float ratioWidth = self.view.bounds.size.width / self.imageView.image.size.width;
	float ratioHeight = self.view.bounds.size.height / self.imageView.image.size.height; 
	
	self.scrollView.zoomScale = MAX(ratioWidth, ratioHeight);
}

- (void)refreshPhotosScrollView:(NSDictionary *)photo 
{	
	self.photo = photo;                 // Setup the model
    
	[self storePhoto];
	[self synchronizeView];
	[self updateZoomScale];             // updateZoomScale to fill up the view
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.scrollView.delegate = self;
	self.splitViewController.delegate = self;	
}

- (void)viewDidUnload
{
    [self setImageView:nil];
	[self setScrollView:nil];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated 
{	
    // Synchronize the view with model
    [self synchronizeView];         
    
	if (self.photo) [self storePhoto];	
}

- (void)viewWillLayoutSubviews 
{     
	// Zoom the image to fill up the view
	if (self.imageView.image) [self updateZoomScale];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
	return self.imageView;
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc 
{
}


@end
