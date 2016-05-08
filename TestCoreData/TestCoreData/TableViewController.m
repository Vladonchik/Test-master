//
//  TableViewController.m
//  TestCoreData
//
//  Created by Vlad Vyshnevskyy on 07/05/2016.
//  Copyright © 2016 VV-SD. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"
#import "Cell.h"
#import "CustomTableViewCell.h"

@interface TableViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController* fetchResultsController;

@property (strong, nonatomic) NSString* entityName;

@property (strong, nonatomic) UIRefreshControl* myRefreshControl;
@end

@implementation TableViewController


- (void)viewDidLoad {
    [super viewDidLoad];

	_entityName = @"Cell";
	
	if ([self entityCount] < 1)
 	{
		[self createNewCellEntity];
	}
	
	[self fetchData];
	[self addRefreshControl];
}

-(void) addRefreshControl
{
	self.myRefreshControl = [[UIRefreshControl alloc] init];
	[self.myRefreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.myRefreshControl];
}

-(void) fetchData
{
	NSError* error = nil;
	if (![[self fetchResultsController] performFetch:&error])
	{
		NSLog(@"Error!  %@", error);
		abort();
	}
	else
	{
		[self.myRefreshControl endRefreshing];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//NSLog(@"%lu", [[self.fetchResultsController sections] count]);
    return [[self.fetchResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchResultsController sections] objectAtIndex:section];
	//NSLog(@"%lu", (unsigned long)[sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* cellReuseIdentifier = @"CustomCell";
    CustomTableViewCell *customCell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
	
	[self configureCell:customCell atIndexPath:indexPath];
	
    return customCell;
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete)
 	{
		NSManagedObject *managedObject = [self.fetchResultsController objectAtIndexPath:indexPath];
		[self.managedObjectContext deleteObject:managedObject];
		[self.managedObjectContext save:nil];
	}
}

#pragma mark -- Deal With Entity --

-(void) createNewCellEntity
{
	Cell* newCellEntity = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
	newCellEntity.header = @"myHeader";
	newCellEntity.footer = @"myFooter";
	newCellEntity.image = @"basket";
	
	[self saveContext];
}


-(void) deleteCellEntity:(UIButton*) sender
{
	id cell = [[sender superview] superview];
	
	if ([cell isKindOfClass:[CustomTableViewCell class]])
	{
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		NSManagedObject *task = [self.fetchResultsController objectAtIndexPath:indexPath];
		[self.managedObjectContext deleteObject:task];
		[self saveContext];
	}
	else
	{
		NSLog(@"Cannot delete row, becuase button's superview is not kind of class CustomTableViewCell");
	}
}


-(void) configureCell:(CustomTableViewCell*) customCell atIndexPath:(NSIndexPath*) indexPath
{
	[customCell.duplicateRow addTarget:self
							 action:@selector(createNewCellEntity)
				   forControlEvents:UIControlEventTouchUpInside];
	
	[customCell.deleteRow addTarget:self
							 action:@selector(deleteCellEntity:)
				   forControlEvents:UIControlEventTouchUpInside];
	
	Cell* cellEntity = [self.fetchResultsController objectAtIndexPath:indexPath];
	
	customCell.headerLabel.text = cellEntity.header;
	customCell.footerLabel.text = cellEntity.footer;
	[customCell.imageView setImage:[UIImage imageNamed:cellEntity.image]];
}

- (void)deleteAllEntities:(NSString *)nameEntity
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:nameEntity];
	[fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
	
	NSError *error;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	for (NSManagedObject *object in fetchedObjects)
	{
		[self.managedObjectContext deleteObject:object];
	}
	
	error = nil;
	[self.managedObjectContext save:&error];
	//[self.fetchResultsController performFetch:nil];
	[self.tableView reloadData];
}

-(NSInteger) entityCount
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	NSError *error = nil;
	
	NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
	if (!error)
	{
		return count;
	}
	else
		return -1;
	
}

#pragma mark - Fetched Results Controller

-(NSFetchedResultsController*) fetchResultsController
{
	if (!_fetchResultsController)
 	{
		NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext* context = [self managedObjectContext];
		
		NSEntityDescription* entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
		
		[fetchRequest setEntity:entity];
		
		NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"header" ascending:YES];
		
		NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		
		fetchRequest.sortDescriptors = sortDescriptors;
		
		_fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
		
		_fetchResultsController.delegate = self;
	}
	return _fetchResultsController;
}

-(NSManagedObjectContext*) managedObjectContext
{
	return [(AppDelegate*) [[UIApplication sharedApplication] delegate]managedObjectContext];
}


-(void) saveContext
{
	NSError* error = nil;
	if ([self.managedObjectContext hasChanges])
	{
		if (![self.managedObjectContext save:&error])
		{
			NSLog(@"Save failed: %@", [error localizedDescription]);
		}
		else
		{
			NSLog(@"Save Succeeded");
		}
	}
}
/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

#pragma mark -- FetchedResultsController Delegate Methods --

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
 
	switch(type)
	{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
    atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
 
	UITableView *tableView = self.tableView;
 
	switch(type)
	{
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
					atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}


@end
