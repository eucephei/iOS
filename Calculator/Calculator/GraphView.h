//
//  GraphView.h
//  Calculator
//
//  Created by ace on 21/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GraphViewDataSource;

@interface GraphView : UIView

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat scale;
@property (weak, nonatomic) IBOutlet id <GraphViewDataSource> dataSource;

@end

@protocol GraphViewDataSource
- (double) functionAtX:(double)xValue;
- (BOOL)   validProgram;
- (BOOL)   lineModeSwitchOn:(GraphView *)sender;
@end
