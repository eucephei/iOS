//
//  Tag+Create.m
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+(NSFetchRequest *)fetchRequestWithFilter:(NSString *)filterText
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Tag"];
    
    // Sort criteria
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *sortByRank = [NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortByRank, sortByName, nil]];
    
    if ([filterText length])
        request.predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", filterText];
    
    return request;
}

+(NSArray *)fetchTagsInContext:(NSManagedObjectContext *)context
{
    // Build fetch request.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    
    // Execute fetch request.
    NSError *error = nil;
    NSArray *fetchedTags = [context executeFetchRequest:request error:&error];
    
    return fetchedTags;
}

+(Tag *) fetchTagWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    // Build fetch request.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"name like[c] %@", name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    // Execute fetch request.
    NSError *error = nil;
    NSArray *fetchedTags = [context executeFetchRequest:request error:&error];
    
    return [fetchedTags lastObject];
}

+ (NSSet *)tagsFromString:(NSString *)string inContext:(NSManagedObjectContext *)context
{
    NSMutableSet *tagSet = nil;
    
    // per assignment, reject tags with a colon ":"
    NSRange textRange =[string rangeOfString:@":"];

    if (textRange.location == NSNotFound) {
        NSArray *tags = [[string capitalizedString] componentsSeparatedByString:@" "];
        tagSet = [[NSMutableSet alloc] initWithCapacity:[tags count]];
        
        for (NSString *tagName in tags) {
            // excludes @"" tagName 
            if ([tagName length]) {       
                Tag* tag = [self fetchTagWithName:tagName inContext:context];
                if (!tag) {
                    tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                                        inManagedObjectContext:context];
                    tag.name = tagName;   
                }
                // higher rank == higher occurence
                tag.rank = [NSNumber numberWithInt:[tag.rank intValue] + 1];  
                
                [tagSet addObject:tag];
            }
        }
    }
    
    return tagSet;
}

@end
