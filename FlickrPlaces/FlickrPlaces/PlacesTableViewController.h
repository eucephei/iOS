//
//  PlacesTableViewController.h
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacesTableViewController : UITableViewController 

@property (nonatomic, strong) NSArray *flickrPlaces;
@property (nonatomic, strong) NSDictionary *selectedFlickrPlaces;
@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)refresh:(id)sender;

@end
