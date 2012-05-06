//
//  BobbleViewController.m
//  Bobble
//
//  Created by ace on 25/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BobbleViewController.h"
#import "Bobble.h"

@implementation BobbleViewController

@synthesize bobble;
@synthesize headView;
@synthesize bodyView;

CGPoint headCenter;
float maxDisplacement;

- (void)dealloc
{
    // Make sure we're no longer the delegate of the shared accelerometer
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    
    [self.bobble removeObserver:self forKeyPath:@"xDisplacement"];
    [self.bobble removeObserver:self forKeyPath:@"yDisplacement"];  
    self.bobble = nil;
    
    [headView release];
    [bodyView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.bobble = [[[Bobble alloc] init] autorelease];
        
        // register to know when displacement changes
        [self.bobble addObserver:self forKeyPath:@"xDisplacement" options:0 context:nil];
        [self.bobble addObserver:self forKeyPath:@"yDisplacement" options:0 context:nil];

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    headCenter = [headView center];
    maxDisplacement = headView.bounds.size.width / 2;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    [self setHeadView:nil];
    [self setBodyView:nil];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    // Set the accelerometer update interval to 10 times per second. When dividing to create a floating point number, make sure that either the numerator or denominator is a float, otherwise you'll end up with an int. For example: (1.0 / 10) is 0.1, whereas (1 / 10) is 0.
    [UIAccelerometer sharedAccelerometer].updateInterval = 0.2;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [bobble adjustSpringsForOrientation:toInterfaceOrientation];
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        headCenter.x = [[UIScreen mainScreen]bounds].size.width / 2.0;
    } else {
        headCenter.x = [[UIScreen mainScreen]bounds].size.height / 2.0;
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
}

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)chg context:(void *)ctxt
{
    if (object == self.bobble) {
        CGPoint newCenter = {
            .x = headCenter.x + self.bobble.xDisplacement * maxDisplacement,
            .y = headCenter.y + self.bobble.yDisplacement * maxDisplacement
        };
        headView.center = newCenter;
    }
}

@end
