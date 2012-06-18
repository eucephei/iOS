//
//  FlickrPlaceAnnotation.h
//  FlickrPlaces
//
//  Created by ace on 13/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSDictionary *place;

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place; 

@end
