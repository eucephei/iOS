//
//  PhotosScrollViewController.m
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoScrollViewController.h"
#import "FlickrService.h"
#import "FlickrRecentPhotos.h"
#import "FlickrImage.h"

@interface PhotoScrollViewController()  
@property (nonatomic, strong) NSDictionary *image;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@end

@implementation PhotoScrollViewController

@synthesize photo = _photo;
@synthesize imageView = _photoView;
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;
@synthesize toolbar = _toolbar;
@synthesize image = _image;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - Accessors

- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo  = photo;  
        
        if (!self.imageView.window) self.imageView.image = nil; 
    }
}

- (void) setPhotoTitle:(NSDictionary *)photo
{   
    // iPHONE
    self.title = [FlickrService titleForPhoto:photo];
    
    // iPAD
     NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
     [[toolbarItems objectAtIndex:[self.toolbar.items count]-2] setTitle:self.title];
    [self.toolbar setItems:toolbarItems];
}

#pragma mark - Setup

- (void)updateZoomScale
{	
    // multiply to get pixels rather than points (for retina)
    CGFloat xPixels = self.scrollView.bounds.size.width * self.scrollView.contentScaleFactor;
    CGFloat yPixels = self.scrollView.bounds.size.height * self.scrollView.contentScaleFactor;
    
    CGFloat xMinZoom = xPixels / self.imageView.image.size.width;
    CGFloat yMinZoom = yPixels / self.imageView.image.size.height;
    CGFloat xMaxZoom = 1 / xMinZoom;
    CGFloat yMaxZoom = 1 / yMinZoom;
    
    self.scrollView.minimumZoomScale = MIN(xMinZoom, yMinZoom);
    self.scrollView.maximumZoomScale = MAX(xMaxZoom, yMaxZoom);
 
    // fix zoomScale above max or below min zoomScale
    self.scrollView.zoomScale = MIN(self.scrollView.zoomScale, self.scrollView.maximumZoomScale);
    self.scrollView.zoomScale = MAX(self.scrollView.zoomScale, self.scrollView.minimumZoomScale);
}

- (void)synchronizeView 
{   
    [self.spinner startAnimating];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        
        NSDictionary* photo = self.photo;
    
        // UIImage* image = [UIImage imageWithData:[FlickrService dataWithContentsOfURLForPhoto:photo format:FlickrPhotoFormatLarge]];
        UIImage* image = [FlickrImage imageForPhoto:photo format:FlickrPhotoFormatLarge];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            /*  ensure image displayed is the originally requested by comparing self.photo (changed by later calls to synchronizeView) with the local photo,                
                iPad: since no segue but image replaced, above essential
                iPhone: seguing creates a new instance of this VC, above unnecessary */        
            if (self.photo == photo) {
                [self.spinner stopAnimating];
                [self setPhotoTitle:photo];
                
                self.imageView.image = image;
                self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
                self.scrollView.contentSize = self.imageView.image.size;
                [self updateZoomScale];
            }
        });
    });
    
    dispatch_release(queue);  
}

- (void)refreshPhotoScrollView:(NSDictionary *)photo 
{	
	self.photo = photo;                         // Setup the model
    
	[FlickrRecentPhotos addPhoto:photo];
	[self synchronizeView];
}

#pragma mark - View lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // in awakeFromNib to ensure proper iPad rotation
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.scrollView.delegate = self;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
	[self setScrollView:nil];
    [self setSpinner:nil];
    [self setToolbar:nil];    
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated 
{	
	if (self.photo) 
        [self synchronizeView];
    else // load newest cached photo 
        self.photo = [[FlickrRecentPhotos retrievePhotos] objectAtIndex:0];

    [self refreshPhotoScrollView:self.photo];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // iPad important
    [self updateZoomScale];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
	return self.imageView;
}

#pragma mark - UISplitViewControllerDelegate



- (void)splitViewController: (UISplitViewController*)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem*)barButtonItem 
       forPopoverController: (UIPopoverController*)pc
{
    // add button to toolbar
    [barButtonItem setTitle:@"Browse"];
    
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:toolbarItems animated:YES];
}

- (void)splitViewController: (UISplitViewController*)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove button from toolbar
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObjectAtIndex:0];
    [self.toolbar setItems:toolbarItems animated:YES];
}

- (BOOL)splitViewController: (UISplitViewController*)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation  
{
    if (self.splitViewController) {
        // iPAD
        return UIInterfaceOrientationIsPortrait(orientation);
    } else {
        // iPHONE
        return NO;
    }
}


@end
