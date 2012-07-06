//
//  VacationsTableViewController.h
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VacationsTableViewControllerModalDelegate
-(void) selectVacationDocument:(UIManagedDocument*) document;
@end

@interface VacationsTableViewController : UITableViewController 

@property (nonatomic, weak) id <VacationsTableViewControllerModalDelegate> delegate;

@end

