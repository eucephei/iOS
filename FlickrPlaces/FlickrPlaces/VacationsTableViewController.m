//
//  VacationsTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 29/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VacationsTableViewController.h"
#import "AskerViewController.h"
#import "VacationTableViewController.h"
#import "VacationHelper.h"

@interface VacationsTableViewController() <AskerViewControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *vacations;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, retain) NSIndexPath *currentPath; // for actionSheet
@end

@implementation VacationsTableViewController

@synthesize vacations = _vacations;
@synthesize addButton = _addButton;
@synthesize actionSheet = _actionSheet;
@synthesize currentPath = _currentPath;
@synthesize delegate = _delegate;

#pragma mark - Accessors

- (UIBarButtonItem *) addButton 
{
    if (!_addButton) {
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    }
    return _addButton;
}

-(UIActionSheet *) actionSheet
{
    if (!_actionSheet) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you absolutely sure?" delegate:self cancelButtonTitle:@"Not yet" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        _actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    }
    return _actionSheet;
}

-(void) popSplitViewController
{
    if (self.splitViewController)  // iPad only
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Target Action

- (void)refresh
{    
    NSArray* vacations = [VacationHelper vacations];
    if (self.vacations.count != vacations.count) {
        self.vacations = [vacations mutableCopy];
        [self.tableView reloadData];
    }
}

- (IBAction)addItem:(id)sender 
{
    [self performSegueWithIdentifier:@"CreateVacation" sender:self];
}

- (IBAction)cancelPressed:(id)sender
{
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // editable if embedded in UITabbarController
    if (!self.presentingViewController) 
        self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Internationalization
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"current locale: %@", locale);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if (editing) {
        self.navigationItem.leftBarButtonItem = [self addButton];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

#pragma mark - UIActionSheetDelegate methods

-(void) deleteVacation
{
    NSIndexPath* path = [self currentPath];
    
    // Delete UIManagedDocument on File
    [VacationHelper removeVacation:[self.vacations objectAtIndex:path.row]];
    
    // Delete the NSString identifier for UIManagedDocument 
    [self.vacations removeObjectAtIndex:path.row];
    
    // Delete the row from the data source
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] 
                     withRowAnimation:UITableViewRowAnimationFade];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
        [self deleteVacation];
}

#pragma mark - Table view delegate

- (NSString*) selectedVacation
{
    return [self.vacations objectAtIndex:self.tableView.indexPathForSelectedRow.row];    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (self.presentingViewController) // !self.tabBarController 
         [VacationHelper openVacation:[self selectedVacation]
                          usingBlock:^(UIManagedDocument *document) {
                              [self.delegate selectVacationDocument:document];
                          }];  
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.vacations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacation Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = [self.vacations objectAtIndex:indexPath.row];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (![self.vacations count]) {
        return UITableViewCellEditingStyleInsert;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
        if (self.vacations.count) {
            self.currentPath = indexPath;
            //[self.actionSheet showInView:self.parentViewController.tabBarController.view];
    [self.actionSheet showInView:self.parentViewController.tabBarController.view];
        }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *vacation = [self.vacations objectAtIndex:fromIndexPath.row];
    
    [self.vacations removeObjectAtIndex:fromIndexPath.row];
    [self.vacations insertObject:vacation atIndex:toIndexPath.row];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - AskerViewControllerDelegate

- (void)askerViewController:(AskerViewController *)sender
             didAskQuestion:(NSString *)question
               andGotAnswer:(NSString *)answer
{
    [VacationHelper openVacation:answer
                      usingBlock:^(UIManagedDocument *document) {
                          [document closeWithCompletionHandler:^(BOOL success) {
                              [self dismissModalViewControllerAnimated:YES];
                              [self popSplitViewController];
                              [self refresh];
                          }];
                      }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowVacation"]) {
        VacationTableViewController *vacationTVC = (VacationTableViewController *)segue.destinationViewController;
        [vacationTVC setTitle:[self selectedVacation]];  
        [vacationTVC setVacation:[self selectedVacation]];
    } 
    
    else if ([segue.identifier hasPrefix:@"CreateVacation"]) {
        AskerViewController *asker = (AskerViewController *)segue.destinationViewController;
        asker.question = @"Name a Vacation";
        asker.answer = [@"My Vacation " stringByAppendingFormat:@"%d", self.vacations.count+1];
        asker.delegate = self;
    }
}

@end
