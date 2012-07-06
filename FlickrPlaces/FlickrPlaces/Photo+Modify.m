//
//  Photo+Modify.m
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Modify.h"
#import "Place+Create.h"
#import "Tag+Create.h"
#import "FlickrService.h"

@implementation Photo (Modify)

-(NSDictionary*) photoInfo
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.flickrInfo];
}

+(NSFetchRequest *) fetchRequestByTag:(Tag *)tag 
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"any tags = %@", tag];
    
    return request;
}

+(NSFetchRequest *) fetchRequestforPlace:(Place *)place
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"whereTook = %@", place];

    return request;
}

+(Photo *) photoWithInfo:(NSDictionary *)photoInfo inContext:(NSManagedObjectContext *)context
{
    NSString* unique = [photoInfo objectForKey:FLICKR_PHOTO_ID];
    
    // returns nil if Photo not found in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    NSError *error = nil;
    
    return [[context executeFetchRequest:request error:&error] lastObject];
}

+(void)addPhoto:(NSDictionary *)photoInfo inContext:(NSManagedObjectContext *)context
{
    Photo *photo = [self photoWithInfo:photoInfo inContext:context];
    
    if (!photo) {
        // Construct Photo from FlickrInfo
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" 
                                              inManagedObjectContext:context];
        
        photo.unique = [photoInfo objectForKey:FLICKR_PHOTO_ID];
        photo.longitude = [photoInfo objectForKey:FLICKR_LONGITUDE];
        photo.latitude = [photoInfo objectForKey:FLICKR_LATITUDE];
        
        photo.title = [FlickrService titleForPhoto:photoInfo];
        photo.subtitle = [FlickrService subtitleForPhoto:photoInfo];
        photo.flickrInfo = [NSKeyedArchiver archivedDataWithRootObject:photoInfo];

        photo.tags = [Tag tagsFromString:[photoInfo objectForKey:FLICKR_TAGS] 
                               inContext:context];
        photo.whereTook = [Place locationAt:[photoInfo objectForKey:FLICKR_PHOTO_PLACE_NAME]
                                  inContext:context];
    }
}

+(void)removePhoto:(NSDictionary *)flickrInfo inContext:(NSManagedObjectContext *)context
{
    Photo *photo = [self photoWithInfo:flickrInfo inContext:context];
    if (photo) {
        for (Tag *tag in photo.tags) {
            tag.rank = [NSNumber numberWithInt:[tag.rank intValue] - 1];
            if (tag.photos.count <= 1) [context deleteObject:tag];      // delete photo's Tag 
        }
        if (photo.whereTook.photos.count <= 1) {
            [context deleteObject:photo.whereTook];                     // delete photo's Place
        }
        [context deleteObject:photo];                                   // delete photo
    }
}

@end
