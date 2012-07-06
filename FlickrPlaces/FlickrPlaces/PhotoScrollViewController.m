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
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation PhotoScrollViewController

@synthesize photo = _photo;
@synthesize image = _image;
@synthesize imageView = _photoView;
@synthesize scrollView = _scrollView;
@synthesize spinner = _spinner;

@synthesize popoverController;      // SplitViewBarButtonItemPresenter
@synthesize toolbar = _toolbar;
@synthesize titleBarButtonItemStr = _titleBarButtonItemStr;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#pragma mark - Accessors

- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo  = photo;  
        
        if (!self.imageView.window) 
            self.imageView.image = nil; 
    }
}

#pragma mark - SplitViewBarButtonItemPresenter 

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    } 
    return detailVC;
}

- (int) reverseIndex 
{
    // if no extra BarButtonItem(s) inserted from the right, then 2
    return [self isMemberOfClass:[PhotoScrollViewController class]] ? 2 : 3;
}

- (NSString *) titleStr
{
    // truncate title length to fit in toolbar
    return self.title.length < 60 ? self.title : [[self.title substringToIndex:60] stringByAppendingString:@"..."];
}

- (void)setTitleBarButtonItemStr:(NSString *)titleBarButtonItemStr
{
    if (_titleBarButtonItemStr != titleBarButtonItemStr) {        
        // iPad only
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [[items objectAtIndex:[items count] - self.reverseIndex] setTitle:self.titleStr];
        
        [self.toolbar setItems:items animated:YES];
        _titleBarButtonItemStr = titleBarButtonItemStr;
    }
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem 
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) 
            [items removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) 
            [items insertObject:splitViewBarButtonItem atIndex:0];
        
        self.toolbar.items = items;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
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
                // iPHONE
                self.title = [FlickrService titleForPhoto:photo];
                // iPAD
                [self splitViewBarButtonItemPresenter].titleBarButtonItemStr = self.title;
                self.imageView.image = image;
                self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
                self.scrollView.contentSize = self.imageView.image.size;
                [self updateZoomScale];
            }
        });
    });
}

- (void) refreshPhotoScrollView:(NSDictionary *)photo 
{	
    if (!photo) return;
    
	self.photo = photo;                         // Setup the mode
    [self synchronizeView];
	[FlickrRecentPhotos addPhoto:photo];
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
    
    // load newest cached photo 
    if (!self.photo) 
        self.photo = [[FlickrRecentPhotos retrievePhotos] objectAtIndex:0];
}

- (void)viewDidUnload
{
    self.imageView = nil;
    self.scrollView = nil;
    self.spinner = nil;
    self.toolbar = nil;
    self.popoverController = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
	self.scrollView.delegate = self;
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
    barButtonItem.title = @"Browse";
    
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
    self.popoverController = pc;
}

- (void)splitViewController: (UISplitViewController*)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove button from toolbar
    
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (BOOL)splitViewController: (UISplitViewController*)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation  
{
    return [self splitViewBarButtonItemPresenter] 
    // iPAD
    ? UIInterfaceOrientationIsPortrait(orientation) 
    // iPHONE
    : NO;
}

@end
