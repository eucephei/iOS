//
//  CalculatorViewController.m
//  CalculatorBrain
//
//  Created by ace on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL showEqualSign;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic , strong ) NSDictionary *testVariableValues;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize variables = _variables;

@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize showEqualSign = _showEqualSign;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setDisplay:nil];
    [self setHistory:nil];   
    [self setVariables:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Accessors

- (CalculatorBrain *) brain 
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

#pragma mark - UIButtons

// helper to update the main display  
- (void) updateDisplay:(NSNumber*)result 
{
    NSLog(@"operation result is: %@", result);
    self.display.text = [NSString stringWithFormat:@"%@",result];
}

// helper for updating history display
- (void)updateHistory:(NSString*)history withEqualSign:(BOOL)equal
{
    NSLog(@"operation history is: %@", history);
    self.history.text = (!equal) 
        ? history
        : [history stringByAppendingFormat:@" ="]; 
    self.showEqualSign = equal;
}

// helper for updating variables display
- (void)updateVariables:(NSSet*)variables
{
    NSLog(@"operation variables are: %@", variables);
    self.variables.text = @"";
    for (NSString *key in variables) {
        NSNumber *value = [self.testVariableValues valueForKey:key];
        NSString* append = [NSString stringWithFormat:@"  %@%@%@  ", key, @" = ", (value) ? value : @"0"];
        self.variables.text = [self.variables.text stringByAppendingString:append];        
    }
}

// changes the sign of the number
-(NSString *)plusMinus:(NSString *)number
{
    if ([number hasPrefix:@"-"])
        number = [number substringFromIndex:1];
    else if ([number doubleValue] != 0)
        number = [@"-" stringByAppendingString:number];
    
    return number;
}

- (IBAction)enterPressed
{
    NSString* variable = self.display.text; 
    double number = [variable doubleValue]; 
    
    if (!number && [variable characterAtIndex:0] != '0')
        [self.brain pushOperand:variable]; 
    else 
        [self.brain pushOperand:[NSNumber numberWithDouble:number]];
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateHistory:[CalculatorBrain descriptionOfProgram:self.brain.program]withEqualSign:NO];
}

- (IBAction)operationPressed:(UIButton*)sender 
{
    NSString *operation = sender.currentTitle;
    NSLog(@"operation is: %@", operation);
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([@"±" isEqualToString:operation]) {
            self.display.text = [self plusMinus:self.display.text];
            return;
        }
        [self enterPressed];
    }

    [self updateDisplay:(NSNumber*)[self.brain performOperation:operation]];
    [self updateHistory:[CalculatorBrain descriptionOfProgram:self.brain.program]withEqualSign:YES];
}

- (IBAction)digitPressed:(UIButton*)sender 
{
    NSString *digit = sender.currentTitle;
    NSRange range = [self.display.text rangeOfString:@"."];
    NSLog(@"digit pressed = %@, range = %@", digit, NSStringFromRange(range));
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if (!([digit isEqual:@"."] && range.location != NSNotFound)) 
            self.display.text = [self.display.text stringByAppendingFormat:digit];
    } else {
        self.display.text = [digit isEqual:@"."] ? @"0." : digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)backspacePressed 
{
    if (self.userIsInTheMiddleOfEnteringANumber){
        self.display.text = [self.display.text substringToIndex:([self.display.text length] - 1)];
        if ([self.display.text length] == 0) {
            self.display.text = @"0"; 
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }
}

- (IBAction)undoPressed
{                 
    [self backspacePressed];
    if (!self.userIsInTheMiddleOfEnteringANumber) {
        [self.brain undo];
        [self updateVariables:[CalculatorBrain variablesUsedInProgram:self.brain.program]];
        [self updateHistory:[CalculatorBrain descriptionOfProgram:self.brain.program] withEqualSign:!self.showEqualSign];
        [self updateDisplay:[CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
    }
}

- (IBAction)clearPressed
{                                 
    self.display.text = @"0";                          // Clear the display
    self.history.text = @"";                           // Clear the history window
    self.variables.text = @"";                         // Clear the variables window
    [self.brain clear];
    self.userIsInTheMiddleOfEnteringANumber = NO;      // Reset user typing boolean
}

- (IBAction)variablePressed:(UIButton *)sender 
{    
    self.display.text = sender.currentTitle;
    [self enterPressed];
}

- (IBAction)testVariableValuesPressed:(UIButton *)sender {
    
    NSString *testVar = sender.currentTitle;
    if ([testVar isEqualToString:@"test 1"]){
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:1.1],@"x",[NSNumber numberWithDouble:0.1],@"y",[NSNumber numberWithDouble:1],@"unused",nil];
    }else if ([testVar isEqualToString:@"test 2"]){
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:-1.1],@"x",[NSNumber numberWithDouble:0.3],@"y",[NSNumber numberWithDouble:2.1],@"z",nil];
    }else if ([testVar isEqualToString:@"test 3"]){
        self.testVariableValues = nil;
    }
    
    NSSet* variables = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    if (variables) { 
        [self updateVariables:variables];
        [self updateDisplay:[CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
    }
}

@end
