//
//  PhotosScrollViewController.h
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface PhotoScrollViewController : UIViewController<SplitViewBarButtonItemPresenter, UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *photo;

- (void)refreshPhotoScrollView:(NSDictionary *)photo;

@end