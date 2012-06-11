//
//  FlickrService.m
//  FlickrPlaces
//
//  Created by ace on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrService.h"

@implementation FlickrService

+ (NSString *)subtitleForPhoto:(NSDictionary *)photo
{
    NSString *subtitle = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION]; 
    if (![subtitle length]) subtitle = @"";
    
    return subtitle;
}

+ (NSString *)titleForPhoto:(NSDictionary *)photo
{
    NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    if (![title length]) {
        title = [self subtitleForPhoto:photo];
        if (![title length]) title = @"Unknown";
    }
    
    return title;
}

+ (NSDictionary *)titlesForPlace:(NSDictionary *)place
{
    NSMutableDictionary* titles = [NSMutableDictionary dictionary];
    
	NSString *placeInfo = [place objectForKey:FLICKR_PLACE_NAME];
	NSRange firstComma = [placeInfo rangeOfString:@","];
   
	if (firstComma.location == NSNotFound) {
        [titles setValue:placeInfo forKey:FLICKR_PHOTO_TITLE];
        [titles setValue:@"" forKey:FLICKR_PHOTO_DESCRIPTION];
	} else {
        NSArray *placeTitles = [placeInfo componentsSeparatedByString:@","];
        [titles setValue:[placeTitles objectAtIndex:0] forKey:FLICKR_PHOTO_TITLE];
        [titles setValue:[placeTitles objectAtIndex:1] forKey:FLICKR_PHOTO_DESCRIPTION];
    }	
    
    return titles;
}

+ (NSArray *)loadTopPlaces
{	
	NSArray *sortDescriptors = [NSArray arrayWithObject:
                                [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]];
    
	return [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:sortDescriptors];
}

+ (NSString *)parseCountryForPlace:(NSDictionary *)place
{
	NSString *placeInfo = [place objectForKey:FLICKR_PLACE_NAME];
	NSRange lastComma = [placeInfo rangeOfString:@"," options:NSBackwardsSearch];
    
    return (lastComma.location == NSNotFound) ? @"" : [placeInfo substringFromIndex:lastComma.location+2];
}

+ (NSDictionary *)loadSelectPlaces:(NSArray *)topPlaces
{
	NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    
	for (NSDictionary *place in topPlaces) {
		NSString *country = [self parseCountryForPlace:place];	
		if (![placesByCountry objectForKey:country]) 
			[placesByCountry setObject:[NSMutableArray array] forKey:country];
		[(NSMutableArray *)[placesByCountry objectForKey:country] addObject:place];		
	}
    
	return placesByCountry;
}

@end
