//
//  FlickrImage.m
//  FlickrPlaces
//
//  Created by ace on 13/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrImage.h"

#define CACHE_SUBDIR @"images"
#define CACHE_SUBDIR_LARGE @"large"
#define CACHE_SUBDIR_SQUARE @"square"
#define CACHE_SUBDIR_UNDEFINED @"undefined"
#define CACHE_LIMIT_MAX 10*1024*1024                            // ~10 MB 
#define CACHE_LIMIT_MIN 8*1024*1024                             // ~8 MB

@implementation FlickrImage

static NSFileManager* _fileManager;
static NSString* _cacheSubdir;
static NSUInteger _cacheSize;

#pragma - mark Accessors

+(NSFileManager*) fileManager
{
    if (_fileManager == nil)
        _fileManager = [[NSFileManager alloc] init];
    return _fileManager;
}

+(NSString*) cacheSubdir
{
    if (_cacheSubdir == nil) 
        _cacheSubdir = [[[[[self fileManager] URLsForDirectory:NSCachesDirectory 
                                                     inDomains:NSUserDomainMask]
                          lastObject] path] stringByAppendingPathComponent:CACHE_SUBDIR];
    return _cacheSubdir;
}

+(void) createCacheSubdir
{
    [[self fileManager] createDirectoryAtPath:[self cacheSubdir] 
                  withIntermediateDirectories:NO attributes:nil error:nil];
} 

+(NSUInteger) sizeOfDirectoryAtPath:(NSString*) path
{
    // very expensive function, rarely call
    NSFileManager *fileManager = [self fileManager];
    NSArray *files = [fileManager subpathsOfDirectoryAtPath:path error:nil];
    NSUInteger totalSize = 0;
    for (NSString *file in files) {
        NSDictionary* attribs = [fileManager attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:nil];
        totalSize += [[attribs objectForKey:NSFileSize] unsignedLongLongValue];
    }
    return totalSize;
}

+(NSUInteger) cacheSize
{
    if (_cacheSize == 0)
        _cacheSize = [self sizeOfDirectoryAtPath:[self cacheSubdir]];
    return _cacheSize;
}

+(void) setCachSize:(NSUInteger) size
{
    _cacheSize = size;
}

#pragma mark - Thread & Cached image loading

+(NSString *)cachedDirForFormat:(FlickrPhotoFormat)format
{
    switch (format) {
        case FlickrPhotoFormatLarge:
            return CACHE_SUBDIR_LARGE;
        case FlickrPhotoFormatSquare:
            return CACHE_SUBDIR_SQUARE;
        default:
            return CACHE_SUBDIR_UNDEFINED;
    }
}

+(id) imageFilePathForPhoto:(NSDictionary*)photo format:(FlickrPhotoFormat)format
{
    NSString* imageFilePath = [[[self cacheSubdir] 
                                stringByAppendingPathComponent:[photo objectForKey:FLICKR_PHOTO_ID]] 
                               stringByAppendingString:[self cachedDirForFormat:format]];
    
    BOOL cached = [[self fileManager] isReadableFileAtPath:imageFilePath];
    if (!cached)
        return imageFilePath;
    else 
        return [[NSData alloc] initWithContentsOfFile:imageFilePath];
}

+(void) cacheImageWithData:(NSData*)data filePath:(NSString*)path
{
    [self createCacheSubdir];
    [data writeToFile:path atomically:YES];
    
    NSFileManager *fileMgr = [self fileManager];
    NSString* cacheDir = [self cacheSubdir];
    NSUInteger cacheSize = [self cacheSize];
    
    NSDictionary* attribs = [fileMgr attributesOfItemAtPath:path error:nil];
    NSUInteger newFilesize = [[attribs objectForKey:NSFileSize] unsignedLongLongValue];
    cacheSize += newFilesize;
    [self setCachSize:cacheSize];
    
    // limit cache size
    if (cacheSize > CACHE_LIMIT_MAX) {
        NSMutableArray *files = [[fileMgr subpathsOfDirectoryAtPath:cacheDir error:nil] mutableCopy];
        
        // sort from newest to oldest
        [files sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString* filePath1 = [cacheDir stringByAppendingPathComponent:obj1];
            NSString* filePath2 = [cacheDir stringByAppendingPathComponent:obj2];
            NSDictionary* attribs1 = [fileMgr attributesOfItemAtPath:filePath1 error:nil];
            NSDictionary* attribs2 = [fileMgr attributesOfItemAtPath:filePath2 error:nil];
            NSDate* date1 = [attribs1 objectForKey:NSFileCreationDate];
            NSDate* date2 = [attribs2 objectForKey:NSFileCreationDate];
            return [date1 compare:date2];  
        }];
        
        NSUInteger filesize;
        for (NSString *file in files) {
            NSString* filename = [cacheDir stringByAppendingPathComponent:file];
            NSDictionary* attribs = [fileMgr attributesOfItemAtPath:filename error:nil];
            filesize = [[attribs objectForKey:NSFileSize] unsignedLongLongValue];
            [fileMgr removeItemAtPath:filename error:nil];
            
            // continue evacuating till min is reached to allow more images to come in,
            // not triggering this expensive function on each cached image
            cacheSize -= filesize;
            if (cacheSize <= CACHE_LIMIT_MIN)
                break;
        }
        
        [self setCachSize:cacheSize];
    }
}

+ (UIImage*) imageForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format
{
    NSData* imageData;
    
    // check if image is in cache, load it, else request it from Flickr
    id cachedData = [self imageFilePathForPhoto:photo format:format];
    
    // cache miss, fetch it 
    if (![cachedData isKindOfClass:[NSData class]]) {
        // sleep(5);  // simulate slow connection        
        imageData = [FlickrService dataWithContentsOfURLForPhoto:photo format:format];
        
        // NSLog(@"fetch image data with length: %x", imageData.length);
        [self cacheImageWithData:imageData filePath:cachedData];
    } 
    
    // cache hit, use it
    else {
        // NSLog(@"Cache hit");
        imageData = (NSData*) cachedData;
    }
    
    return [[UIImage alloc] initWithData:imageData];
}

@end
