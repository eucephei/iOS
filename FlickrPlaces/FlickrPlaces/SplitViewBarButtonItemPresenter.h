//
//  SplitViewBarButtonItemPresenter.h
//  FlickrPlaces
//
//  Created by ace on 18/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SplitViewBarButtonItemPresenter       // iPad only

@property (nonatomic, strong) UIPopoverController *popoverController; 
@property (nonatomic, strong) UIToolbar *toolbar; 
@property (nonatomic, weak) NSString *titleBarButtonItemStr;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *splitViewBarButtonItem;

@optional
@property (nonatomic, weak) IBOutlet UIBarButtonItem *visitButton;

@end
