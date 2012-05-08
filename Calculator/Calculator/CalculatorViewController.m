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
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSMutableArray *history;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize displayHistory = _displayHistory;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize history = _history;

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
    [self setDisplayHistory:nil];    
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

#define kHistoryCapacity 20 

- (NSMutableArray *)history
{
    if (!_history)
        _history = [[NSMutableArray alloc] initWithCapacity:kHistoryCapacity];
    return _history;
}

- (CalculatorBrain *) brain 
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

#pragma mark - UIButtons

// helper function for updating history
- (void)updateHistory:(NSString *)withText
{
    NSAssert(self.history.count <= kHistoryCapacity, @"ERROR: History too long");
    if (self.history.count == kHistoryCapacity)
        [self.history removeObjectAtIndex:0];
    [self.history addObject:withText];
    self.displayHistory.text = [self.history componentsJoinedByString:@" "]; 
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
        self.display.text = ([digit isEqual:@"."]) ? @"0." : digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    [self updateHistory:self.display.text];
}

- (IBAction)operationPressed:(UIButton*)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    
    double result = [self.brain performOperation:sender.currentTitle];
    NSLog(@"calculated result is: %f", result);
    NSString *resultString = [NSString stringWithFormat:@"%g", result];
    self.display.text = resultString;
    
    [self updateHistory:sender.currentTitle];
    NSLog(@"current title is: %@", sender.currentTitle);

    // [self updateHistory:sender.currentTitle];
    self.displayHistory.text = [self.displayHistory.text stringByAppendingString:@" ="]; 
}

- (IBAction)plusMinusPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text hasPrefix:@"-"])
            self.display.text = [self.display.text substringFromIndex:1];
        else
            self.display.text = [NSString stringWithFormat:@"-%@",self.display.text];
        return;
    }
    
    double result = [self.brain performOperation:sender.currentTitle];
    self.display.text = [NSString stringWithFormat:@"%g",result];
    
    [self updateHistory:sender.currentTitle];
    self.displayHistory.text = [self.displayHistory.text stringByAppendingString:@" ="]; 
}

- (IBAction)clearPressed
{
    [self.brain reset];
    self.history = nil;                                 
    self.display.text = @"0";                           // Clear the display
    self.displayHistory.text = @"";                       // Clear the history window
    self.userIsInTheMiddleOfEnteringANumber = NO;       // Reset user typing boolean
}

- (IBAction)backspacePressed 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text length] > 1) {
            self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        } else {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }
}



@end
