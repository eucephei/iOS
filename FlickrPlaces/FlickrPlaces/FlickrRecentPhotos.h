//
//  FlickrRecentPhotos.h
//  FlickrPlaces
//
//  Created by ace on 13/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrRecentPhotos : NSObject

+ (NSArray *)retrievePhotos;
+ (void) addPhoto:(NSDictionary*)photo;

@end
