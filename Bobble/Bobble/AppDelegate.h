//
//  AppDelegate.h
//  Bobble
//
//  Created by ace on 25/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BobbleViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) IBOutlet BobbleViewController *viewController;

@end
