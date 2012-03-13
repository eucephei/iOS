//
//  USAStateDetailViewController.m
//  USATable
//
//  Created by ace on 12/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "USAStateDetailViewController.h"

#import "USAState.h"
#import <QuartzCore/QuartzCore.h>

@interface USAStateDetailViewController ()
 @property (nonatomic,retain) USAState* state;
@end

@implementation USAStateDetailViewController

@synthesize flagImageView = _flagImageView;
@synthesize state = _state;

- (void)dealloc
{
	self.state = nil;
	self.flagImageView = nil;
	
	[super dealloc];
}

- (id) initWithState:(USAState *)state 
{
	self = [self initWithNibName:nil bundle:nil];
	if ( self == nil ) {
		return self;
	}
	
	self.state = state;
	self.title = [NSString stringWithFormat:@"%@ (%@)", [state valueForKey:@"name"], [state valueForKey:@"abbreviation"], nil]; // [state valueForKey:@"name"];
	
	return self;
}

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
	UIImage* flagImage = [UIImage imageWithContentsOfFile:[self.state pathForLargeImage]];	
	self.flagImageView.image = flagImage;    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated 
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

typedef enum {
	StateDetailSectionCities = 0,
	StateDetailSectionDates,
	StateDetailSectionNumbers,
	STATE_DETAIL_SECTION_COUNT,
} StateDetailSection;

typedef enum {
	StateDetailSectionCitiesRowCapital = 0,
	StateDetailSectionCitiesRowPopulous,
	STATE_DETAIL_SECTION_CITIES_ROWCOUNT,
} StateDetailSectionCitiesRow;

typedef enum {
	StateDetailSectionDatesRowStatehood = 0,
	STATE_DETAIL_SECTION_DATES_ROWCOUNT,
} StateDetailSectionDatesRow;

typedef enum {
	StateDetailSectionNumbersRowPopulation = 0,
	StateDetailSectionNumbersRowArea,
	STATE_DETAIL_SECTION_NUMBERS_ROWCOUNT,
} StateDetailSectionNumbersRow;

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView 
{
    //	NSLog(@"%s", __PRETTY_FUNCTION__);
	return STATE_DETAIL_SECTION_COUNT;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    //	NSLog(@"%s : section=%i", __PRETTY_FUNCTION__, section);
	NSInteger count = 0;
	switch ( section ) {
		case StateDetailSectionCities:
			count = STATE_DETAIL_SECTION_CITIES_ROWCOUNT;
			break;
			
		case StateDetailSectionDates:
			count = STATE_DETAIL_SECTION_DATES_ROWCOUNT;
			break;
			
		case StateDetailSectionNumbers:
			count = STATE_DETAIL_SECTION_NUMBERS_ROWCOUNT;
			break;
		default:
			break;
	}
	return count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    //NSLog(@"%s : { section=%i, row=%i }", __PRETTY_FUNCTION__, indexPath.section, indexPath.row);
	UITableViewCell* cell = nil;
	switch ( indexPath.section ) {
            
		case StateDetailSectionCities: {
			static NSString* CitiesCellIdentifier = @"CitiesCell";
			cell = [self.tableView dequeueReusableCellWithIdentifier:CitiesCellIdentifier];
			if ( cell == nil ) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CitiesCellIdentifier] autorelease];
			}
            
			switch ( indexPath.row ) {
				case StateDetailSectionCitiesRowCapital:
					cell.textLabel.text = @"Capital";
					cell.detailTextLabel.text = [self.state valueForKey:@"capital"];
					break;
					
				case StateDetailSectionCitiesRowPopulous:
					cell.textLabel.text = @"Largest";
					cell.detailTextLabel.text = [self.state valueForKey:@"populousCity"];
					break;
			}
			break;
		}
			
		case StateDetailSectionDates:{
			static NSString* CitiesCellIdentifier = @"DatesCell";
			cell = [self.tableView dequeueReusableCellWithIdentifier:CitiesCellIdentifier];
			if ( cell == nil ) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CitiesCellIdentifier] autorelease];
			}
			
			switch ( indexPath.row ) {
				case StateDetailSectionDatesRowStatehood:
					cell.textLabel.text = @"Statehood";
					cell.detailTextLabel.text = [NSDateFormatter 
                            localizedStringFromDate:[self.state valueForKey:@"date"]
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterNoStyle];
					break;
				default:
					break;
			}
			break;
		}
			
		case StateDetailSectionNumbers: {
			static NSString* CitiesCellIdentifier = @"NumbersCell";
			cell = [self.tableView dequeueReusableCellWithIdentifier:CitiesCellIdentifier];
			if ( cell == nil ) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CitiesCellIdentifier] autorelease];
			}
			
			switch ( indexPath.row ) {
				case StateDetailSectionNumbersRowPopulation:
					cell.textLabel.text = @"Population";
					cell.detailTextLabel.text = [NSNumberFormatter 
                            localizedStringFromNumber:[self.state valueForKey:@"population"]
                                          numberStyle:NSNumberFormatterDecimalStyle];
					break;
				case StateDetailSectionNumbersRowArea:
					cell.textLabel.text = @"Area (sq.mi.)";
					cell.detailTextLabel.text = [NSNumberFormatter 
                            localizedStringFromNumber:[self.state valueForKey:@"area"]
                                          numberStyle:NSNumberFormatterDecimalStyle];
					break;
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	// Observe how this doesn't round the corners in grouped tables
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor magentaColor];
    cell.selectedBackgroundView = view;
    [view release];
	
	return cell;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section 
{
    //	NSLog(@"%s : section=%i", __PRETTY_FUNCTION__, section);
	NSString* title = nil;
	switch ( section ) {
		case StateDetailSectionCities:
			title = @"Cities";
			break;
		case StateDetailSectionDates:
			break;
		case StateDetailSectionNumbers:
			break;
		default:
			break;
	}
	return title;
}

- (NSString*) tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section 
{
    //	NSLog(@"%s : section=%i", __PRETTY_FUNCTION__, section);
	NSString* title = nil;
	switch ( section ) {
		case StateDetailSectionCities:
			break;
		case StateDetailSectionDates:
			break;
		case StateDetailSectionNumbers:
			title = @"\nPopulation and Largest City based on 2010 Census Data\n\n";
			break;
		default:
			break;
	}
	return title;
}

@end
