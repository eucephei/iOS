//
//  Place+Create.h
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"

@interface Place (Create)

+(NSFetchRequest *) fetchRequestByDate;

+(NSArray *) fetchPlacesInContext:(NSManagedObjectContext *)context;

+(Place *) locationAt:(NSString *)location 
            inContext:(NSManagedObjectContext *)context;

@end
