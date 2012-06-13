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

+ (NSString *)descriptionForPlace:(NSDictionary *)place
{
    NSString *description = [place objectForKey:FLICKR_PLACE_NAME]; 
    
    NSRange firstComma = [description rangeOfString:@","];
	if (firstComma.location != NSNotFound) 
        description = [description substringFromIndex:firstComma.location + 1];
    
    return description;
}

+ (NSArray *)titlesForPlace:(NSDictionary *)place
{
    NSArray* titles;
    
    NSString *description = [place objectForKey:FLICKR_PLACE_NAME];
    NSRange firstComma = [description rangeOfString:@","];
    if (firstComma.location != NSNotFound) 
        titles = [description componentsSeparatedByString:@","];  
    else 
        titles = [NSArray arrayWithObjects:description, @"", nil];
    
    return titles;
}

+ (NSURL *)urlForPhoto:(NSDictionary *)photo
{
    return [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
}

+ (NSData *)dataWithContentsOfURLForPhoto:(NSDictionary *)photo
{
    return [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatLarge]];
}

+ (NSArray *)photosInPlace:(NSDictionary *)place
{
    return [FlickrFetcher photosInPlace:place maxResults:FLICKR_PHOTOS_MAX];
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
