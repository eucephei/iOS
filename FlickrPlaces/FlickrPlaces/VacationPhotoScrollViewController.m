//
//  VacationPhotoScrollViewController.m
//  FlickrPlaces
//
//  Created by ace on 30/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationPhotoScrollViewController.h"
#import "VacationsTableViewController.h"
#import "FlickrService.h"
#import "Photo+Modify.h"
#import "CustomAlertView.h"

#define VISIT @"Visit"
#define UNVISIT @"Unvisit"

@interface VacationPhotoScrollViewController() <VacationsTableViewControllerModalDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UILabel *tagListLabel;
@property (nonatomic, strong) CustomAlertView *alertView;
@end

@implementation VacationPhotoScrollViewController

@synthesize documentContext = _documentContext;
@synthesize tagListLabel = _tagListLabel;
@synthesize alertView = _alertView;
@synthesize visitButton = _visitButton;

#pragma mark - Accessors

-(void) setDocumentContext:(NSManagedObjectContext *)documentContext
{
    _documentContext = documentContext;
    self.visitButton.title = documentContext ? UNVISIT : VISIT;
}

-(CustomAlertView *) alertView
{
    if (!_alertView) {
        _alertView = [[CustomAlertView alloc] initWithTitle:@"Are you sure?"
                                                message:@"a memory is priceless..."
                                               delegate:self
                                      cancelButtonTitle:@"Not yet"
                                      otherButtonTitles:nil]; 
        [_alertView addButtonWithTitle:@"Unvisit"];
    }
    return _alertView;
}

#pragma mark - Target Action

- (IBAction)clearTagListLabel:(id)sender
{
    self.tagListLabel.text = nil;
}

- (IBAction)visitButtonPressed:(id)sender
{
    if (self.documentContext) {
        // unvisiting
        [self.alertView show];
    } else {
        // visiting 
        [self performSegueWithIdentifier:@"SelectVacation" sender:self];
    }
}

#pragma mark - Setup

- (void)refreshPhotoScrollView:(NSDictionary *)photo 
{	
    // photo not already in Vacation(s), so can visit
    if (!self.documentContext || self.photo != photo) 
        self.documentContext = nil;
    
    [super refreshPhotoScrollView:photo];

    // print UILabel
    NSArray* tags = [self.photo objectForKey:FLICKR_TAGS];
    self.tagListLabel.text = (NSString *)tags;
    
    // add tap to UILabel
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearTagListLabel:)];
    [self.tagListLabel addGestureRecognizer:tap];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    self.visitButton = nil;
    self.tagListLabel = nil;
    self.alertView = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    [self refreshPhotoScrollView:self.photo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UIAlertViewDelegate

-(void) unvisitPhoto
{
    // saveToURL to document delayed
    [Photo removePhoto:self.photo inContext:self.documentContext];
    self.documentContext = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) 
        [self unvisitPhoto];
}

#pragma mark - VacationsTableViewControllerModalDelegate

-(void) selectVacationDocument:(UIManagedDocument *)document
{
    // visit photo in this document
    self.documentContext = document.managedObjectContext;
    
    // saveToURL to document now
    [Photo addPhoto:self.photo inContext:self.documentContext];
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            [self dismissModalViewControllerAnimated:YES];
            self.documentContext = nil;
    }];
}

#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SelectVacation"]) {
        
        VacationsTableViewController *vc = segue.destinationViewController;
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = (VacationsTableViewController *)((UINavigationController *)vc).topViewController;
        }
        // VacationsTableViewControllerModalDelegate
        vc.delegate = self;
        
        // on iPad, also dismiss popOverController 
        if ([self.popoverController isPopoverVisible]) 
            [self.popoverController dismissPopoverAnimated:YES];
    }
}

@end
