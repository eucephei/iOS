//
//  GraphViewController.m
//  Calculator
//
//  Created by ace on 21/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "FavoritesPopoverTableViewController.h"
#import "FavoritesPushedTableViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"
#import "VariableValues.h"

#define KEY_FAVORITES               @"GraphViewController.favorites"

@interface GraphViewController ()  <FavoritesSelectionProtocol, GraphViewDataSource>
@property (nonatomic, strong) VariableValues *variableValues;
@property (nonatomic, weak)   IBOutlet GraphView *graphView;
@property (nonatomic, weak)   IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak)   IBOutlet UISwitch *lineModeSwitch;
@property (nonatomic, weak)   IBOutlet UILabel *programDescriptionLabel;
@property (nonatomic, strong) IBOutlet UIPopoverController *myPopoverController;
@end

@implementation GraphViewController

@synthesize program                 = _program;
@synthesize variableValues          = _variableValues;

@synthesize graphView               = _graphView;
@synthesize toolbar                 = _toolbar;
@synthesize lineModeSwitch          = _lineModeSwitch;
@synthesize programDescriptionLabel = _programDescriptionLabel;
@synthesize myPopoverController     = _myPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Accessors

- (VariableValues *)variableValues
{
    if (!_variableValues) _variableValues = [[VariableValues alloc] init];
    
    return _variableValues;
}

- (void)describeProgram:(NSString *)description
{
    BOOL changed = NO;
    if (self.toolbar) {      
        // iPAD
        NSMutableArray * items = [[self.toolbar items] mutableCopy];
        for (int i = 0; i < items.count; i++) {
            UIBarButtonItem * b = [items objectAtIndex:i];
            if (b.style == UIBarButtonItemStylePlain) {
                [b setTitle:description];
                changed = YES;
            }
        }
        if (changed) [self.toolbar setItems:items];
    } else {
        // iPHONE
        self.programDescriptionLabel.text = description;
        [self.programDescriptionLabel setNeedsDisplay];
    }
}

- (void)setProgram:(id)program
{
    _program = program;
    [self.graphView setNeedsDisplay];
    
    [self describeProgram:[CalculatorBrain descriptionOfProgram:self.program]];
    [self.programDescriptionLabel setNeedsDisplay];
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    
    self.graphView.backgroundColor = [UIColor whiteColor];
    
    // Pinching changes the scale
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    
    // Panning moves the origin
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];     
    
    // Double-tap sets a new origin
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(doubleTap:)];
    tapgr.numberOfTapsRequired = 2;
    [self.graphView addGestureRecognizer:tapgr];
}

#pragma mark - GraphViewDataSource

- (double)functionAtX:(double)xValue 
{
    NSNumber* xNum = [[NSNumber alloc] initWithDouble:xValue];
    NSMutableDictionary * varsDict = self.variableValues.dict;
    [varsDict setValue:xNum forKey:@"x"];
    double yValue = [[CalculatorBrain runProgram:self.program usingVariableValues:varsDict] doubleValue];
    
    return yValue;
}

- (BOOL) validProgram
{
    return (self.program != nil);
}

- (BOOL) lineModeSwitchOn:(GraphView *)sender
{
    return self.lineModeSwitch.on;
}

- (IBAction) lineModeSwitchAction 
{
    [self.graphView setNeedsDisplay];
}

#pragma - mark FavoritesSelectionProtocol

- (void)selectedProgram:(id)program byTableViewController:(UITableViewController *)sender
{
    self.program = program;
}

#pragma - mark SplitViewDelegate

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void) splitViewController:(UISplitViewController *)svc
      willHideViewController:(UIViewController *)aViewController
           withBarButtonItem:(UIBarButtonItem *)barButtonItem
        forPopoverController:(UIPopoverController *)pc
{
    // add button to toolbar
    barButtonItem.title = @"Calculator";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.myPopoverController = pc;
} 

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove button from toolbar
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.myPopoverController = nil;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    if (self.splitViewController) {
        // iPAD
        return UIInterfaceOrientationIsPortrait(orientation);
    } else {
        // iPHONE
        return NO;
    }
}

#pragma mark - Favorites

// same action for both iPAD and iPHONE
- (IBAction)addProgramToFavorite 
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults]; 
    assert(prefs);
    
    NSMutableArray * programs = [[prefs arrayForKey:KEY_FAVORITES] mutableCopy];
    if (!programs) programs = [[NSMutableArray alloc] init];
    [programs addObject:self.program];
    
    [prefs setObject:programs forKey:KEY_FAVORITES];
    [prefs synchronize];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    assert(prefs);
    
    if ([segue.identifier isEqualToString:@"PopoverFavorites"]) {
        // iPAD
        FavoritesPopoverTableViewController * controller = segue.destinationViewController; 
         controller.programs = [prefs arrayForKey:KEY_FAVORITES];
         controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PushFavorites"]) {
        // iPHONE
        FavoritesPushedTableViewController * controller = segue.destinationViewController; 
         controller.programs = [prefs arrayForKey:KEY_FAVORITES];
         controller.delegate = self;
    }
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // this controller is dataSource for the graphView
    self.graphView.dataSource = self;
    
    [self.graphView setNeedsDisplay];
}

- (void)viewDidUnload
{
    self.graphView = nil;
    self.programDescriptionLabel = nil;
    self.program = nil;
    self.toolbar = nil;
 
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self describeProgram:[CalculatorBrain descriptionOfProgram:self.program]];
    [self.programDescriptionLabel setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


@end
