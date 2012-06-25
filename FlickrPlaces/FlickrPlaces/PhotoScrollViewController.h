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
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar; // iPad only

- (void)refreshPhotoScrollView:(NSDictionary *)photo;

@end
