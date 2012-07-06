//
//  VacationTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationTableViewController.h"
#import "VacationHelper.h"
#import "Place+Create.h"
#import "Tag+Create.h"

@interface VacationTableViewController()
@property (nonatomic, strong) UIManagedDocument* document;
@end

@implementation VacationTableViewController

@synthesize vacation = _vacation;
@synthesize document = _document;

#pragma mark - NSNotificationCenter

- (void)contextChanged:(NSNotification *)notification
{
    id deleteObj = [notification.userInfo valueForKey:NSDeletedObjectsKey];
    if (deleteObj) 
        NSLog(@"Document object to be deleted: %@", deleteObj);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [[NSNotificationCenter defaultCenter] addObserver:self 
                    selector:@selector(contextChanged:)
                        name:NSManagedObjectContextObjectsDidChangeNotification
                      object:self.document.managedObjectContext];
    
    [VacationHelper openVacation:self.vacation 
                      usingBlock:^(UIManagedDocument *document) {
                          self.document = document;
                          [self.tableView reloadData];
                      }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                      name:NSManagedObjectContextObjectsDidChangeNotification
                    object:self.document.managedObjectContext];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Search Cell";
    if (!indexPath.row) CellIdentifier = @"Itinerary Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    NSArray *places = [Place fetchPlacesInContext:self.document.managedObjectContext];  
    NSArray *tags = [Tag fetchTagsInContext:self.document.managedObjectContext];

    cell.textLabel.text = !indexPath.row ? @"Itinerary" : @"Tag Search";
    cell.detailTextLabel.text = !indexPath.row 
        ? [NSString stringWithFormat:@"%d places", places.count] 
        : [NSString stringWithFormat:@"%d tags", tags.count];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:!indexPath.row ? @"ShowItinerary" : @"ShowTags" sender:self];
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id vc = segue.destinationViewController;
    if ([vc respondsToSelector:@selector(setDocument:)])
        [vc setDocument:self.document];
}

@end
