//
//  FlickrRecentPhotos.m
//  FlickrPlaces
//
//  Created by ace on 13/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrRecentPhotos.h"
#import "FlickrService.h"

@implementation FlickrRecentPhotos

+ (NSArray *) retrievePhotos
{
	NSArray *photos = [[[[NSUserDefaults standardUserDefaults] objectForKey:FLICKR_PHOTOS_RECENT] reverseObjectEnumerator] allObjects];
    
    if ([photos count] == 0)
        photos = [FlickrService topPlaces];
    
    return photos;
}

+ (void) addPhoto:(NSDictionary*)photo
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
    NSMutableArray *recentPhotos = [[defaults objectForKey:FLICKR_PHOTOS_RECENT] mutableCopy];
	if (!recentPhotos) recentPhotos = [NSMutableArray array];
    
    // remove oldest photo if list too long
	if (recentPhotos.count > FLICKR_PHOTOS_MAX)  
		[recentPhotos removeObjectAtIndex:0];
	
    // remove old photo identifical to one just selected
	NSString *photoID = [photo objectForKey:FLICKR_PHOTO_ID];
	for (int i = 0; i < recentPhotos.count; i++) {
		NSDictionary *photo = [recentPhotos objectAtIndex:i];
		if ([[photo objectForKey:FLICKR_PHOTO_ID] isEqualToString:photoID]) {
			[recentPhotos removeObject:photo];
			continue;
		}        
	}
    
    // add selected photo
	[recentPhotos addObject:photo];
    
	[defaults setObject:recentPhotos forKey:FLICKR_PHOTOS_RECENT];
	[defaults synchronize];
}

@end
