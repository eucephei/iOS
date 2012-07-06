//
//  TagsTableViewController.m
//  FlickrPlaces
//
//  Created by ace on 30/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagsTableViewController.h"
#import "VacationPhotosTableViewController.h"
#import "Photo+Modify.h"
#import "Tag+Create.h"

@interface TagsTableViewController() <UINavigationControllerDelegate, UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@end

@implementation TagsTableViewController

@synthesize searchBar = _searchBar;
@synthesize document = _document;

#pragma mark - Accessors

-(NSString *) vacationName  // REDO
{
    // fetch the vacation's name from the document
    NSString *documentName = nil;
    NSError *errorForName = nil;
    [self.document.fileURL getResourceValue:&documentName forKey:NSURLNameKey error:&errorForName]; 
    
    return documentName;
}

-(void) filterTags:(NSString*)tagText
{
    NSFetchRequest *request = [Tag fetchRequestWithFilter:tagText];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.navigationItem.title = @"Tags";
}

-(void) setDocument:(UIManagedDocument *)document
{
    _document = document;
    [self filterTags:nil];
}

-(void) popViewControllerIfNoTag
{
    if (!self.fetchedResultsController.fetchedObjects.count)
        [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // self.title = @"Tags";
    self.navigationController.delegate = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
}

- (void)viewDidUnload
{
    self.searchBar = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self popViewControllerIfNoTag];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = (tag.photos.count == 1)
        ? @"1 photo"
        : [NSString stringWithFormat:@"%i photos", tag.photos.count];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    [self performSegueWithIdentifier:@"ShowTagPhotos" sender:self];
}

# pragma mark - UISearchBarDelegate 

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterTags:searchText];
}

#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id vc = segue.destinationViewController;
    if ([vc respondsToSelector:@selector(setRequest:inContext:)]) {
        
        Tag* tag = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        NSFetchRequest *request = [Photo fetchRequestByTag:tag];     
        
        [vc setRequest:request inContext:self.document.managedObjectContext];
        [vc setTitle:tag.name];
    }
}


@end
