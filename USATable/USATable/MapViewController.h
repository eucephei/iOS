//
//  MapViewController.h
//  USATable
//
//  Created by ace on 12/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *_mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end
