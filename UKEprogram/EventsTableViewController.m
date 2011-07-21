//
//  EventsTableViewController.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "EventsTableViewController.h"
#import "EventDetailsViewController.h"
#import "UKEprogramAppDelegate.h"
#import "JSON.h"
#import "Event.h"
#import "FilterViewController.h"
#import "FriendsTableViewController.h"

@implementation EventsTableViewController

@synthesize eventDetailsViewController;
@synthesize listOfEvents;
@synthesize datePicker;
@synthesize filterViewController;

UIButton *filterButton;
UIButton *datePickButton;
//NSDate *firstDate;
//int days;
NSMutableArray *sectListOfEvents;
static int secondsInDay = 86400;
/**
 * Called to sort and show list of events
 */
-(void)updateTable {
    //sort by starting date
    NSLog(@"Updating table");
    [sectListOfEvents release];
    sectListOfEvents = [[NSMutableArray alloc] init];
    if ([listOfEvents count] > 0) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"showingTime" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [listOfEvents sortUsingDescriptors:sortDescriptors];
        [sortDescriptor release];
    
        [sectListOfEvents release];
        sectListOfEvents = [[NSMutableArray alloc] init];
    
        //Find first date (with time set to 00:00:00)
        Event *e = (Event *)[listOfEvents objectAtIndex:0];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comp = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: e.showingTime];
        NSDate *firstDate = [gregorian dateFromComponents:comp];
    
        //add events to sections based on time since firstdate
        int lastDay = 0;
        int thisDay;
        NSArray *events = [[NSArray alloc] init];
        for (int i = 0; i < [listOfEvents count]; i++) {
            e = (Event *)[listOfEvents objectAtIndex:i];
            thisDay = (int)[e.showingTime timeIntervalSinceDate:firstDate]/secondsInDay;
            NSLog(@"Days since last event: %i", thisDay);
            if (thisDay != lastDay) {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:events forKey:@"Events"];
                [sectListOfEvents addObject:dict];
                events = [[NSArray alloc] init];
            }
            lastDay = thisDay;
            events = [events arrayByAddingObject:e];
        
        }
        NSDictionary *dict = [NSDictionary dictionaryWithObject:events forKey:@"Events"];
        [sectListOfEvents addObject:dict];
    
        [gregorian release];
        [eventsTableView reloadData];
        //[sectListOfEvents release];
        datePicker.minimumDate = [[listOfEvents objectAtIndex:0] showingTime];
        datePicker.date = [[listOfEvents objectAtIndex:0] showingTime];
        datePicker.maximumDate = [[listOfEvents objectAtIndex:[listOfEvents count]-1] showingTime];
    }
    NSLog(@"Table updatet");
    
}

-(void)showEventsWithPredicate:(NSPredicate *)predicate
{
    NSError *error;
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *con = [delegate managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:con];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSMutableArray *array = [[con executeFetchRequest:request error:&error] mutableCopy];
    [self setListOfEvents:array];
    [self updateTable];
}

/**
 *   Fetches all the events in the object context and displays them
 */
-(void)showAllEvents{
    [self showEventsWithPredicate:Nil];
    [filterButton setTitle:@"Alle" forState:UIControlStateNormal];
}
-(void)showFavoriteEvents{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorites == %i", 1];
    [self showEventsWithPredicate:predicate];
    [filterButton setTitle:@"Favoritt" forState:UIControlStateNormal];
}
-(void)showKonsertEvents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType == %@", @"konsert"];
    [self showEventsWithPredicate:predicate];
    [filterButton setTitle:@"Konsert" forState:UIControlStateNormal];
}
-(void)showRevyEvents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType == %@", @"revy-og-teater"];
    [self showEventsWithPredicate:predicate];
    [filterButton setTitle:@"Favoritt" forState:UIControlStateNormal];
}
-(void)showKursEvents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType == %@", @"andelig-fode"];
    [self showEventsWithPredicate:predicate];
    [filterButton setTitle:@"Favoritt" forState:UIControlStateNormal];
}
-(void)showFestEvents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType == %@", @"fest-og-moro"];
    [self showEventsWithPredicate:predicate];
    [filterButton setTitle:@"Favoritt" forState:UIControlStateNormal];
}

-(void) scrollToDate:(NSDate *)date animated: (BOOL)animated
{
    Event *e;
    NSIndexPath *scrollPath;
    BOOL found = NO;
    for (int i = 0; i < [sectListOfEvents count]; i++) {
        for (int j = 0; j < [[[sectListOfEvents objectAtIndex:i] objectForKey:@"Events"] count]; j++) {
            e = (Event *) [[[sectListOfEvents objectAtIndex:i] objectForKey:@"Events"] objectAtIndex:j];
            if (((long)[e.showingTime  timeIntervalSinceDate:date]) > 0 && !found) {
                scrollPath = [NSIndexPath indexPathForRow:j inSection:i];
                found = YES;
                NSLog(@"Scroller til %@", e.title);
            }
        }
    }
    if (found) {
        [[self tableView] scrollToRowAtIndexPath:scrollPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self.eventDetailsViewController release];
    [sectListOfEvents release];
    [super dealloc];
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
    listOfEvents = [[NSMutableArray alloc] init];
    [self.datePicker addTarget:self action:@selector(datePickChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker addTarget:self action:@selector(datePickClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.datePicker setHidden:YES];
    self.navigationItem.title = @"Program";
    filterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    datePickButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    filterButton.frame = CGRectMake(0, 0, 45, 30);
    datePickButton.frame = CGRectMake(45, 0, 45, 30);
    filterButton.tag = 3;
    datePickButton.tag = 4;
    [filterButton addTarget:self action:@selector(comboClicked:) forControlEvents:UIControlEventTouchUpInside];
    [datePickButton addTarget:self action:@selector(calClicked:) forControlEvents:UIControlEventTouchUpInside];
    [datePickButton setTitle:@"Dato" forState:UIControlStateNormal];
    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 5, 90, 30)];
    [toolbar addSubview:filterButton];
    [toolbar addSubview:datePickButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
}

- (void)viewDidUnload
{
    [sectListOfEvents release];
    [filterButton release];
    [datePickButton release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (CGPoint) makeGoodPickerPosition
{
    CGPoint topLeft = [self.tableView contentOffset];
    topLeft.x = 160;
    topLeft.y = topLeft.y + 310;
    return topLeft;
}

- (void) datePickChanged:(id)sender
{
    [self.tableView setScrollEnabled:YES];
    [self scrollToDate:[datePicker date] animated:NO];
    [self.tableView setScrollEnabled:NO];
    [self.datePicker setCenter:[self makeGoodPickerPosition]];
}
- (void) hideDatePicker
{
    [datePicker removeFromSuperview];
    [self.datePicker setHidden:YES];
    [self.tableView setScrollEnabled:YES];
}

- (void)calClicked:(id)sender
{
    if ([self.datePicker isHidden]) {
        [self.tableView insertSubview:datePicker aboveSubview:self.parentViewController.view];
        [self.datePicker setHidden:NO];
        [self.tableView setContentOffset:[self.tableView contentOffset] animated:NO];
        [self.datePicker setCenter:[self makeGoodPickerPosition]];
        [self.tableView setScrollEnabled:NO];
    } else {
        [self hideDatePicker];
    }
    
}


- (void)comboClicked:(id)sender
{
    self.filterViewController = [[FilterViewController alloc] initWithNibName:@"FilterView" bundle:nil];
    [self.filterViewController setEventsTableViewController:self];
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.rootController pushViewController:filterViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[filterButton setHidden:NO];
    //[datePickButton setHidden:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[filterButton setHidden:YES];
    //[datePickButton setHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return 1;
    NSLog(@"section count: %i", [sectListOfEvents count]);
    return [sectListOfEvents count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [listOfEvents count];
    NSDictionary *dict = [sectListOfEvents objectAtIndex:section];
    NSLog(@"section %i count: %i", section, [[dict objectForKey:@"Events"] count]); 
    return [[dict objectForKey:@"Events"] count];
}

- (void)favoritesClicked:(id)sender event:(id)event
{
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil) {
        NSError *error;
        UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *con = [delegate managedObjectContext];
        
        Event *e = (Event *)[[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = (UIButton *)[cell viewWithTag:3];
        if ([e.favorites intValue] > 0) {
            e.favorites = [NSNumber numberWithInt:0];
            [button setBackgroundImage:delegate.uncheckedImage forState:UIControlStateNormal];
        }
        else {
            e.favorites = [NSNumber numberWithInt:1];
            [button setBackgroundImage:delegate.checkedImage forState:UIControlStateNormal];
        }
        if (![con save:&error]) {
            NSLog(@"Lagring av %@ feilet", e.title);
        } else {
            NSLog(@"Lagret event %@", e.title);
        }
    }
}

/**
 *  returns a view for displaying each event in the table
 */
- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
    
    CGRect CellFrame = CGRectMake(0, 0, 300, 60);
    CGRect Label1Frame = CGRectMake(10, 5, 290, 20);
    CGRect Label2Frame = CGRectMake(15, 27, 285, 13);
    
    UILabel *lblTemp;
    
    
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier] autorelease];
    
    //Initialize Label with tag 1.
    lblTemp = [[UILabel alloc] initWithFrame:Label1Frame];
    lblTemp.tag = 1;
    [cell.contentView addSubview:lblTemp];
    [lblTemp release];
    
    //Initialize Label with tag 2.
    lblTemp = [[UILabel alloc] initWithFrame:Label2Frame];
    lblTemp.tag = 2;
    lblTemp.font = [UIFont boldSystemFontOfSize:12];
    lblTemp.textColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:lblTemp];
    [lblTemp release];
    
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CGRect ButtonFrame = CGRectMake(230, 5, delegate.uncheckedImage.size.width, delegate.uncheckedImage.size.height);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = ButtonFrame;
    button.tag = 3;
    [button addTarget:self action:@selector(favoritesClicked:event:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:button];
    
    return cell;
}



/**
 *  Displays events in the table
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    /*if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }*/
    if (cell == nil) {
        cell = [self getCellContentView:CellIdentifier];
    }
    
    // Configure the cell...
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:2];
    UIButton *button = (UIButton *)[cell viewWithTag:3];
    //Event *e = (Event *) [listOfEvents objectAtIndex:indexPath.row];
    Event *e = (Event *) [[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row];
    
    titleLabel.text = e.title;
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [delegate.onlyTimeFormat stringFromDate:e.showingTime], e.place];
    
    if ([e.favorites intValue] > 0) {
        [button setBackgroundImage:delegate.checkedImage forState:UIControlStateNormal];
    }
    else {
        [button setBackgroundImage:delegate.uncheckedImage forState:UIControlStateNormal];
    }
    
    return cell;
}
/*
 * Sets header to section remove if sections isnt used
 */
- (NSString *)tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section {
    Event *e = (Event *) [[[sectListOfEvents objectAtIndex:section] objectForKey:@"Events"] objectAtIndex:0];
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *s = [delegate.weekDays objectAtIndex:[[delegate.weekDayFormat stringFromDate:e.showingTime] intValue]];
    return [NSString stringWithFormat:@"%@ %@", s, [delegate.onlyDateFormat stringFromDate:e.showingTime]];
}
    





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate
/**
 *  Creates a new detailed view of an event
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (eventDetailsViewController == nil) {
        EventDetailsViewController *aController = [[EventDetailsViewController alloc] initWithNibName:@"EventDetailsView" bundle:nil];
        self.eventDetailsViewController = aController;
        [aController release];
    }*/
    if (![datePicker isHidden]) {
        [self hideDatePicker];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else {
        self.eventDetailsViewController = [[EventDetailsViewController alloc] initWithNibName:@"EventDetailsView" bundle:nil];
    
        //eventDetailsViewController.event = (Event *)[listOfEvents objectAtIndex:indexPath.row];
        eventDetailsViewController.event = (Event *) [[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row];
        UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.rootController pushViewController:eventDetailsViewController animated:YES];
    }
}
@end