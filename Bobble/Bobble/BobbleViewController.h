//
//  BobbleViewController.h
//  Bobble
//
//  Created by ace on 25/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bobble;

@interface BobbleViewController : UIViewController  {
    UIImageView *headView;
    UIImageView *bodyView;
}

@property (nonatomic, retain) IBOutlet Bobble *bobble;
@property (nonatomic, retain) IBOutlet UIImageView *headView;
@property (nonatomic, retain) IBOutlet UIImageView *bodyView;


@end
