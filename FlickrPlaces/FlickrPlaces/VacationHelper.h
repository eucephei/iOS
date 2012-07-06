//
//  VacationHelper.h
//  FlickrPlaces
//
//  Created by ace on 27/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VacationHelper : NSObject

typedef void (^completion_block_t)(UIManagedDocument *vacation);

+ (void)openVacation:(NSString *)vacationName
          usingBlock:(completion_block_t)completionBlock;

+ (void)removeVacation:(NSString *)vacationName;

+ (NSArray *)vacations;

@end
