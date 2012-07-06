//
//  VacationPhotoScrollViewController.h
//  FlickrPlaces
//
//  Created by ace on 30/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoScrollViewController.h"

@interface VacationPhotoScrollViewController : PhotoScrollViewController  

@property (nonatomic, strong) NSManagedObjectContext* documentContext;

@end
