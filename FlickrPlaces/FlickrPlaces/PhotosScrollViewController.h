//
//  PhotosScrollViewController.h
//  FlickrPlaces
//
//  Created by ace on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosScrollViewController : UIViewController<UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

- (void)refreshPhotosScrollView:(NSDictionary *)photo;

@end
