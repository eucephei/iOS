//
//  CalculatorViewController.m
//  CalculatorBrain
//
//  Created by ace on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "GraphViewController.h"
#import "CalculatorBrain.h"
#import "VariableValues.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL showEqualSign;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) VariableValues *variableValues;
@end

@implementation CalculatorViewController

@synthesize display                             = _display;
@synthesize displayLog                          = _displayLog;
@synthesize displayVariables                    = _displayVariables;

@synthesize userIsInTheMiddleOfEnteringANumber  = _userIsInTheMiddleOfEnteringANumber;
@synthesize showEqualSign                       = _showEqualSign;
@synthesize brain                               = _brain;
@synthesize variableValues                      = _variableValues;

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
    [self setDisplayLog:nil];   
    [self setDisplayVariables:nil];
    
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
    if (self.splitViewController)                                           // iPAD
        return YES;
    else                                                                    // iPHONE
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - Accessors

- (CalculatorBrain *) brain 
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (VariableValues *)variableValues
{
    if (!_variableValues) _variableValues = [[VariableValues alloc] init];
    return _variableValues;
}

#pragma mark - UIButtons

- (NSNumber *) programResult
{
    return [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.variableValues.dict];
}

- (NSString *) programDescription
{
    return [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (NSSet *) programVariables
{
    return [CalculatorBrain variablesUsedInProgram:self.brain.program];
}

- (void) updateDisplay:(NSNumber*)result 
{
    // NSLog(@"operation result is: %@", result);
    self.display.text = [NSString stringWithFormat:@"%@",result];
}

- (void)updateDisplayLog:(NSString*)log withEqualSign:(BOOL)equal
{
    // NSLog(@"operation log is: %@", log);
    self.displayLog.text = (!equal) ? log : [log stringByAppendingFormat:@" ="]; 
    self.showEqualSign = equal;
}

- (void)updateDisplayVariables:(NSSet*)variables           
{
    // NSLog(@"operation variables are: %@", variables);
    self.displayVariables.text = @"";
    for (NSString *key in variables) {
        NSNumber *value = [self.variableValues.dict valueForKey:key];
        NSString* append = [NSString stringWithFormat:@"  %@%@%@  ", key, @" = ", (value) ? value : @"0"];
        self.displayVariables.text = [self.displayVariables.text stringByAppendingString:append];        
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
    [self updateDisplayLog:[self programDescription] withEqualSign:NO];
}

- (IBAction)operationPressed:(UIButton*)sender 
{
    NSString *operation = sender.currentTitle;
    // NSLog(@"operation is: %@", operation);
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([@"±" isEqualToString:operation]) {
            self.display.text = [self plusMinus:self.display.text];
            return;
        }
        [self enterPressed];
    }
    
    [self updateDisplay:(NSNumber*)[self.brain performOperation:operation]];
    [self updateDisplayLog:[self programDescription] withEqualSign:YES];
}

- (IBAction)digitPressed:(UIButton*)sender 
{
    NSString *digit = sender.currentTitle;
    NSRange range = [self.display.text rangeOfString:@"."];
    // NSLog(@"digit pressed = %@, range = %@", digit, NSStringFromRange(range));
    
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
    if (self.userIsInTheMiddleOfEnteringANumber) {
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
        [self updateDisplay:[self programResult]];
        [self updateDisplayVariables:[self programVariables]];
        [self updateDisplayLog:[self programDescription] withEqualSign:!self.showEqualSign];
    }
}

- (IBAction)allClearPressed
{
    self.display.text = @"0";                       // Clear the display
    self.userIsInTheMiddleOfEnteringANumber = NO;   // Reset user typing boolean
    
    [self.brain clear];
    self.displayLog.text = @"";                     // Clear the log window
    self.displayVariables.text = @"";               // Clear the variables window
}

- (IBAction)variablePressed:(UIButton *)sender 
{    
    self.display.text = sender.currentTitle;
    [self enterPressed];
}

- (IBAction)variableValuePressed
{
    NSString *variable = [[self.displayLog.text componentsSeparatedByString:@" "] lastObject]; 
    NSNumber *variableValue = [NSNumber numberWithDouble:[self.display.text doubleValue]];
    
    if ([self.variableValues.dictKeys containsObject:variable]) {
        [self.variableValues.dict setValue:variableValue forKey:variable];
        [self updateDisplayLog:variable withEqualSign:YES];
        [self updateDisplayVariables:self.variableValues.dictKeys];
    }    
} 

- (IBAction)variableValueEval
{
    NSSet* variables = [self programVariables];
    if (variables) { 
        [self updateDisplay:[self programResult]];
        [self updateDisplayVariables:variables];
    }
}

- (IBAction)graphPressed
{   
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    
    if ([detailViewController isKindOfClass:[GraphViewController class]]) 
        // iPAD: updates program in the graph at the right (detail) pane
        [detailViewController setProgram:self.brain.program];
    else 
        // iPHONE: segue to Graph
        if ([self.brain.program count] > 0)
            [self performSegueWithIdentifier:@"ShowGraph" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // iPAD: Send program to graph pane
    // iPHONE: Bring up Graph by Segue
    if ([segue.identifier isEqualToString:@"ShowGraph"]) 
        [segue.destinationViewController setProgram:self.brain.program];
}


@end
