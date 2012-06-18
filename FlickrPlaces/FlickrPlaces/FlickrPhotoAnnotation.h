//
//  FlickrPhotoAnnotation.h
//  FlickrPlaces
//
//  Created by ace on 13/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSDictionary *photo;

+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo; 

@end
