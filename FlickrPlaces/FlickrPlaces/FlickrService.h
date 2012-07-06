//
//  FlickrService.h
//  FlickrPlaces
//
//  Created by ace on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrFetcher.h"

#define FLICKR_PHOTOS_MAX 50
#define FLICKR_PHOTOS_RECENT @"PhotosScrollViewController.recent"

@interface FlickrService : FlickrFetcher

+ (NSString *)subtitleForPhoto:(NSDictionary *)photo;
+ (NSString *)titleForPhoto:(NSDictionary *)photo;

+ (NSString *)countryForPlace:(NSDictionary *)place;
+ (NSString *)descriptionFromPlace:(NSString *)place;
+ (NSString *)descriptionForPlace:(NSDictionary *)place;
+ (NSString *)titleFromPlace:(NSString *)place;
+ (NSString *)titleForPlace:(NSDictionary *)place;
+ (NSArray *)titlesForPlace:(NSDictionary *)place;

+ (NSURL *)urlForPhoto:(NSDictionary *)photo;
+ (NSData *)dataWithContentsOfURLForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format;
+ (NSArray *)photosInPlace:(NSDictionary *)place;

+ (NSArray *)topPlaces; 
+ (NSDictionary *)selectTopPlaces:(NSArray *)topPlaces;

@end
