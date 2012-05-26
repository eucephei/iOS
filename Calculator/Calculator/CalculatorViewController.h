//
//  CalculatorViewController.h
//  CalculatorBrain
//
//  Created by ace on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *displayLog;
@property (weak, nonatomic) IBOutlet UILabel *displayVariables;

- (IBAction)enterPressed;
- (IBAction)operationPressed:(UIButton*)sender;
- (IBAction)digitPressed:(UIButton*)sender;
- (IBAction)backspacePressed;
- (IBAction)undoPressed;
- (IBAction)allClearPressed;
- (IBAction)variablePressed:(UIButton *)sender; 
- (IBAction)variableValuePressed;
- (IBAction)variableValueEval;
- (IBAction)graphPressed;

@end
