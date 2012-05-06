//
//  MapViewController.m
//  USATable
//
//  Created by ace on 12/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

#import "USAState.h"
#import "FlagAnnotationView.h"
#import "USAStateDetailViewController.h"

static NSString* const UserLocationOnMapKeyPath = @"mapView.userLocation.location";

@implementation MapViewController

@synthesize mapView = _mapView;

- (void)dealloc
{
	[self removeObserver:self forKeyPath:UserLocationOnMapKeyPath];
    [_mapView release];
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		self.title = @"Map";
		self.tabBarItem.image = [UIImage imageNamed:@"103-map.png"];
		
		[self addObserver:self
               forKeyPath:UserLocationOnMapKeyPath
                  options:0
                  context:nil];
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
	NSArray* states = [USAState sortedStates];
	[self.mapView addAnnotations:states];
	
	self.mapView.showsUserLocation = NO;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation 
{
	if ( annotation == mapView.userLocation ) {
		// use default annotation view for user's location
		return nil;
	}
	
	FlagAnnotationView* view = [FlagAnnotationView flagAnnotationViewForMapView:mapView];
	// assume annotation is a USAState
	view.flagImage.image = [(USAState*)annotation smallImage];
	return view;
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	// assume annotation is a USAState
	USAState* state = (USAState*)view.annotation;
	USAStateDetailViewController* controller = [[USAStateDetailViewController alloc] initWithState:state];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( [keyPath isEqualToString:UserLocationOnMapKeyPath] ) {
		self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
	}
}

@end
