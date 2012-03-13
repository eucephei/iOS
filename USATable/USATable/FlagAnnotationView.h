//
//  FlagAnnotationView.h
//  USATable
//
//  Created by ace on 11/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FlagAnnotationView : MKAnnotationView {
	UIImageView *flagImage;
}

// the image property needs to be set
@property (nonatomic, retain) IBOutlet UIImageView *flagImage;

+ (id) flagAnnotationViewForMapView:(MKMapView*)mapView;

@end
