//
//  Tag+Create.h
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+(NSFetchRequest *)fetchRequestWithFilter:(NSString *)filterText;

+(NSArray *)fetchTagsInContext:(NSManagedObjectContext *)context;

+(NSSet *)tagsFromString:(NSString *)string 
                inContext:(NSManagedObjectContext *)context;

@end
