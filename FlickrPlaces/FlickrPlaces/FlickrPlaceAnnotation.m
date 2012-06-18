//
//  FlickrPlaceAnnotation.m
//  FlickrPlaces
//
//  Created by ace on 13/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrService.h"

@implementation FlickrPlaceAnnotation

@synthesize place = _place;

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title         // city
{
    return [FlickrService titleForPlace:self.place];            
}

- (NSString *)subtitle      // region
{
    return [FlickrService descriptionForPlace:self.place];     
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    
    return coordinate;
}



@end
