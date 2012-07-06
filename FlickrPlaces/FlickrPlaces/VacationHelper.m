//
//  VacationHelper.m
//  FlickrPlaces
//
//  Created by ace on 27/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationHelper.h"

#define VACATIONS_DIR @"Vacations"

@implementation VacationHelper

static NSString* _vacationsSubdir;

+(NSString*) vacationsSubdir
{
    if (_vacationsSubdir == nil) 
        _vacationsSubdir = [[[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path] stringByAppendingPathComponent:VACATIONS_DIR];
    
    return _vacationsSubdir;
}

+(void) createVacationsSubdir
{
    [[NSFileManager defaultManager] createDirectoryAtPath:[self vacationsSubdir] 
           withIntermediateDirectories:NO attributes:nil error:nil];
}

+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock
{
    // create app folder, in which has vacations
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self vacationsSubdir]])
        [self createVacationsSubdir];
    
    // vacation url, document
    NSURL *url = [NSURL fileURLWithPath:[[self vacationsSubdir] stringByAppendingPathComponent:vacationName]];
    UIManagedDocument *doc = [[UIManagedDocument alloc] initWithFileURL:url];
    
    // file not exists, create it
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        [doc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (!success) NSLog(@"Couldn't create document at %@", url);  
            else completionBlock(doc);
        }];    
    }
    
    // or open it
    else if (doc.documentState == UIDocumentStateClosed){
        [doc openWithCompletionHandler:^(BOOL success){
            if (!success) NSLog (@"Couldn't open document at %@", url);
            else completionBlock(doc);
        }];
    }
}

+ (void)removeVacation:(NSString *)vacationName
{
    // create app folder, in which has vacations
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self vacationsSubdir]])
        [self createVacationsSubdir];
    
    // vacation url, document
    NSURL *url = [NSURL fileURLWithPath:[[self vacationsSubdir] stringByAppendingPathComponent:vacationName]];

    // file exists, delete it
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        if (![[NSFileManager defaultManager] removeItemAtURL:url error:nil])
            NSLog (@"Couldn't delete document at %@", url);
    }   
}

+(NSArray*) vacations
{    
    // array of NSString objects identifying file, directory or symbolic link
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self vacationsSubdir] error:nil];
    
    return files;
}

@end
