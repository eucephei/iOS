//
//  MapViewController.m
//  FlickrPlaces
//
//  Created by ace on 14/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

#define MAP_TYPE @"map_type"
#define MAP_PIN_VIEW @"map_pin_view" 
#define MAP_REGION_MARGIN .002

@implementation MapViewController

@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize mapView = _mapView;
@synthesize mapType = _mapType;

#pragma mark - Utilities

-(void) updateMapWithAnnotations:(NSArray*) annotations
{
    // skip this expensive function if mapView not ready yet
    if (!self.mapView || !annotations || !annotations.count) return;
    
    // attach annotations
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotations];
    
    // zoom/pan map to a proper size
    CLLocationDegrees minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (id <MKAnnotation> annotation in annotations) {
        CLLocationCoordinate2D coord = [annotation coordinate];
        if (coord.latitude < minLat) minLat = coord.latitude;
        if (coord.latitude > maxLat) maxLat = coord.latitude;
        if (coord.longitude < minLng) minLng = coord.longitude;
        if (coord.longitude > maxLng) maxLng = coord.longitude;
    }
    
    // set region's center, span
    MKCoordinateRegion region;
    region.center.latitude = (maxLat + minLat)/2.0;
    region.center.longitude = (maxLng + minLng)/2.0;
    region.span.latitudeDelta = (maxLat - minLat + MAP_REGION_MARGIN);
    region.span.longitudeDelta = (maxLng - minLng + MAP_REGION_MARGIN);
    
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - Accessors

-(void) setAnnotations:(NSArray *)annotations
{
    if (_annotations != annotations) {
        _annotations = annotations;
        
        // this do nothing if view (from prepareForSegue) not yet loaded 
        [self updateMapWithAnnotations:annotations];
    }
}

#pragma mark - Target Action

- (IBAction)changeMapType:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0: self.mapView.mapType = MKMapTypeStandard; break;
        case 1: self.mapView.mapType = MKMapTypeSatellite; break;
        case 2: self.mapView.mapType = MKMapTypeHybrid; break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.mapView.mapType] forKey:MAP_TYPE];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;

    // add annotations to mapView
    [self updateMapWithAnnotations:self.annotations];
    
    // set map type
    NSNumber *savedMapType = [[NSUserDefaults standardUserDefaults] objectForKey:MAP_TYPE];
    if (savedMapType != nil) {
        self.mapView.mapType = [savedMapType integerValue];
        self.mapType.selectedSegmentIndex = [savedMapType integerValue];
    }
}

- (void)viewDidUnload
{
    [self setMapType:nil];
    [self setMapView:nil];

    [super viewDidUnload];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - MKMapViewDelegate methods

-(MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:MAP_PIN_VIEW];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:MAP_PIN_VIEW];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    /* build (but not load) thumbnail accessory is not redundant because same MapView is reused between different delegates */
    view.leftCalloutAccessoryView =  (![self.delegate annotationHasThumbnail]) 
        ? nil 
        : [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    view.annotation = annotation;
    
    return view;
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // load the thumbnail in a separate thread
    UIImageView *thumbnailView = (UIImageView*) view.leftCalloutAccessoryView;
    if (thumbnailView) {
        thumbnailView.image = nil;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            id <MKAnnotation> annotation = view.annotation;
            UIImage* image = [self.delegate thumbnailForAnnotation:annotation];
            
            /* ensure only imageView that originally appeared are modified,
             as imageViews are reused, by comparing the local annotation 
             copied on stack and the annotation from mapView:viewForAnnotation */
            dispatch_async(dispatch_get_main_queue(), ^{
                if (thumbnailView.window && view.annotation == annotation)
                    thumbnailView.image = image;
            });
        });
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [(UIImageView *)view.leftCalloutAccessoryView setImage:nil];
}

-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view 
calloutAccessoryControlTapped:(UIControl *)control
{
    if ([control isKindOfClass:[UIButton class]]) 
        [self.delegate showPhotoForAnnotation:view.annotation];  
}

@end
