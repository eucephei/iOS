//
//  MapViewController.h
//  FlickrPlaces
//
//  Created by ace on 14/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController <UISplitViewControllerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) NSArray* annotations; // id<MKAnnotation>
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapType;

@end



@protocol MapViewControllerDelegate <NSObject>
-(BOOL) annotationHasThumbnail;
-(void) showPhotoForAnnotation:(id <MKAnnotation>)annotation;
@optional
- (UIImage *)thumbnailForAnnotation:(id <MKAnnotation>)annotation;
@end

