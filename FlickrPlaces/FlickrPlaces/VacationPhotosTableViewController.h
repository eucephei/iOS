//
//  VacationPhotosTableViewController.h
//  FlickrPlaces
//
//  Created by ace on 30/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PhotosTableViewController.h"

@interface VacationPhotosTableViewController : PhotosTableViewController

@property (nonatomic, strong) NSFetchRequest* request;
@property (nonatomic, strong) NSManagedObjectContext* documentContext;
@property (nonatomic, strong) NSString* title;

-(void) setRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext*) context;

@end
