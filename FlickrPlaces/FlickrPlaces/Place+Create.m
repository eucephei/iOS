//
//  Place+Create.m
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Create.h"

@implementation Place (Create)

+(NSFetchRequest *) fetchRequestByDate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"visitDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return request;
}

+(NSArray *) fetchPlacesInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self fetchRequestByDate];
    NSError *error = nil;

    return [context executeFetchRequest:request error:&error];
}

+(Place *) fetchPlaceWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    // returns nil if Place not found in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error = nil;
    
    return [[context executeFetchRequest:request error:&error] lastObject];
}

+(Place *) locationAt:(NSString *)location inContext:(NSManagedObjectContext *)context
{
    Place *place = [self fetchPlaceWithName:location inContext:context];
    
    if (!place) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" 
                                              inManagedObjectContext:context];
        place.name = location;
        place.visitDate = [NSDate date];
    }
    
    return place;
}

@end
