//
//  BattleshipViewController.h
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define MAX_HITS 9

#import <UIKit/UIKit.h>

@class BattleshipGridView;

@interface BattleshipViewController : UIViewController <UIScrollViewDelegate> {
	UIButton *gameKitButton;
}

@property (nonatomic, retain) IBOutlet BattleshipGridView *gridView;
@property (nonatomic, retain) IBOutlet BattleshipGridView *opponentGridView;
@property (nonatomic, retain) IBOutlet UILabel *gridLabel;
@property (nonatomic, retain) IBOutletCollection(UIView) NSArray* ships;
@property (nonatomic, retain) IBOutlet UIButton *beginGameButton;
@property (nonatomic, retain) IBOutlet UIView *playerPageControl;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *playerPageControlLabel;
@property (nonatomic, retain) IBOutlet UILabel *opponentPageControlLabel;
@property (nonatomic, retain) IBOutlet UIButton *gameKitButton;

- (IBAction)beginGame:(id)sender;
- (IBAction)changeGridPage:(id)sender;
- (IBAction)choosePeer:(id)sender;

@end
