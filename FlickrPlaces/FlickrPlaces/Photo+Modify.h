//
//  Photo+Modify.h
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@interface Photo (Modify)

@property (readonly) NSDictionary* photoInfo;

+(NSFetchRequest *)fetchRequestByTag:(Tag *)tag;
+(NSFetchRequest *)fetchRequestforPlace:(Place *)place;

+(Photo *) photoWithInfo:(NSDictionary *)photoInfo 
               inContext:(NSManagedObjectContext *)context;

+(void)addPhoto:(NSDictionary *)flickrInfo 
      inContext:(NSManagedObjectContext *)context;

+(void)removePhoto:(NSDictionary *)flickrInfo 
         inContext:(NSManagedObjectContext *)context;


@end
