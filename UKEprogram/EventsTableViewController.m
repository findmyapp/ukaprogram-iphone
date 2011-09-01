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
@synthesize eTableView;
@synthesize pickerView;
UIButton *filterButton;
UIButton *datePickButton;
UIButton *editAttendingButton;
UIToolbar *toolbar;
BOOL editAttending;
//int days;
NSMutableArray *sectListOfEvents;
static int secondsInDay = 86400;
static int pickerWidth = 50;
static int pickerOffset = 135;
bool isUsingPicker = NO;


/**
 * Create labels for date-picking horizontal scrollview at top
 */


-(void)createPickerDates
{
    UKEprogramAppDelegate *del = [[UIApplication sharedApplication] delegate];
    NSDateFormatter *onlyDateFormat = del.onlyDateFormat;
    
    for(UIView *subview in [pickerView subviews]) {
        [subview removeFromSuperview];
    }
    CGRect rect = CGRectMake(pickerOffset, 0, pickerWidth, pickerView.bounds.size.height);
    int i;
    for(i = 0; i < sectListOfEvents.count; i++) {
        Event *e = [[[sectListOfEvents objectAtIndex:i] objectForKey:@"Events"] objectAtIndex:0];
        UILabel *lbl = [[UILabel alloc] initWithFrame:rect];
        lbl.font = [UIFont systemFontOfSize:12];
        [lbl setNumberOfLines:2];
        [lbl setText:[NSString stringWithFormat:@"%@\n%@", [del getWeekDay:e.showingTime], [onlyDateFormat stringFromDate:e.showingTime]]];
        [pickerView addSubview:lbl];
        NSLog(@"Added picker %@", lbl.text);
        //[lbl release];
        rect.origin.x += pickerWidth;
    }
    pickerView.contentSize = CGSizeMake(2*pickerOffset+i*pickerWidth, 1);
    
}

/**
 * Called to show list of events
 */
-(void)updateTable {
    //sort by starting date
    NSLog(@"Updating table");
    [sectListOfEvents release];
    sectListOfEvents = [[NSMutableArray alloc] init];
    if ([listOfEvents count] > 0) {
        
    
    
        //Find first date (with time set to 00:00:00)
        Event *e = (Event *)[listOfEvents objectAtIndex:0];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comp = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: e.showingTime];
        NSDate *firstDate = [gregorian dateFromComponents:comp];
    
        //add events to sections based on time since firstdate
        NSNumber *lastDay = 0;
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for (int i = 0; i < [listOfEvents count]; i++) {
            e = (Event *)[listOfEvents objectAtIndex:i];
            if ((int)[e.showingTime timeIntervalSinceDate:firstDate]/secondsInDay != [lastDay intValue]) {
                NSDictionary *dict = [NSDictionary dictionaryWithObject:events forKey:@"Events"];
                [sectListOfEvents addObject:dict];
                [events release];
                events = [[NSMutableArray alloc] init];
            }
            lastDay = [NSNumber numberWithInt:[e.showingTime timeIntervalSinceDate:firstDate]/secondsInDay];
            [events addObject:e];
        }
        [sectListOfEvents addObject:[NSDictionary dictionaryWithObject:events forKey:@"Events"]];
        [events release];
        [gregorian release];
        //[sectListOfEvents release];
        datePicker.minimumDate = [[listOfEvents objectAtIndex:0] showingTime];
        datePicker.date = [[listOfEvents objectAtIndex:0] showingTime];
        datePicker.maximumDate = [[listOfEvents objectAtIndex:[listOfEvents count]-1] showingTime];
    }
    [self createPickerDates];
    NSLog(@"Table updatet");
    [eTableView reloadData];
    
    
}



-(void)showEventsWithPredicate:(NSPredicate *)predicate
{
    NSError *error;
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *con = [delegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"showingTime" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:con];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    [self setListOfEvents:[[con executeFetchRequest:request error:&error] mutableCopy]];
    [request release];
    //[self setListOfEvents:array];
    [self updateTable];
}

/**
 *   Fetches all the events in the object context and displays them
 */
-(void)showAllEvents{
    [self showEventsWithPredicate:Nil];
    //[filterButton setTitle:@"Alle" forState:UIControlStateNormal];
}
-(void)showFavoriteEvents{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorites == %i", 1];
    [self showEventsWithPredicate:predicate];
    
    //[filterButton setTitle:@"Favoritt" forState:UIControlStateNormal];
}
-(void)showKonsertEvents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType == %@", @"konsert"];
    [self showEventsWithPredicate:predicate];
    //[filterButton setTitle:@"Konsert" forState:UIControlStateNormal];
}
-(void)showRevyEvents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType == %@", @"revy-og-teater"];
    [self showEventsWithPredicate:predicate];
    //[filterButton setTitle:@"Favoritt" forState:UIControlStateNormal];
}
-(void)showKursEvents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType == %@", @"andelig-fode"];
    [self showEventsWithPredicate:predicate];
    //[filterButton setTitle:@"Favoritt" forState:UIControlStateNormal];
}
-(void)showFestEvents
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventType == %@", @"fest-og-moro"];
    [self showEventsWithPredicate:predicate];
    //[filterButton setTitle:@"Favoritt" forState:UIControlStateNormal];
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
        [eTableView scrollToRowAtIndexPath:scrollPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)dealloc
{
    /*
    [self.eventDetailsViewController dealloc];
    [self.listOfEvents dealloc];
    [self.filterViewController dealloc];
    [filterButton dealloc];
    [sectListOfEvents dealloc];
    [datePickButton dealloc];
    [editAttendingButton dealloc];
    [toolbar dealloc];*/
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
    
    [eTableView setDelegate:self];
    [eTableView setDataSource:self];
    [pickerView setDelegate:self];
    
    editAttending = NO;
    listOfEvents = [[NSMutableArray alloc] init];
    [self.datePicker addTarget:self action:@selector(datePickChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker addTarget:self action:@selector(datePickClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.datePicker setHidden:YES];
    self.navigationItem.title = @"Program";
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    datePickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame = CGRectMake(-10, 0, 36, 31);
    datePickButton.frame = CGRectMake(26, 0, 36, 31);
    filterButton.tag = 3;
    datePickButton.tag = 4;
    [filterButton addTarget:self action:@selector(comboClicked:) forControlEvents:UIControlEventTouchUpInside];
    [datePickButton addTarget:self action:@selector(calClicked:) forControlEvents:UIControlEventTouchUpInside];
    //[datePickButton setTitle:@"Dato" forState:UIControlStateNormal];
    [filterButton setImage:[UIImage imageNamed:@"choose_button"] forState:UIControlStateNormal];
    [datePickButton setImage:[UIImage imageNamed:@"calendar_button"] forState:UIControlStateNormal];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 5, 62, 31)];
    
    editAttendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editAttendingButton.frame = CGRectMake(62, 0, 36, 31);
    //[editAttendingButton setTitle:@"edit" forState:UIControlStateNormal];
    [editAttendingButton setImage:[UIImage imageNamed:@"delta_pressed"] forState:UIControlStateNormal];
    [editAttendingButton addTarget:self action:@selector(editAttendingClicked:) forControlEvents:UIControlEventTouchUpInside];
    editAttendingButton.tag = 5;
    [editAttendingButton retain];
    
    [toolbar addSubview:filterButton];
    [toolbar addSubview:datePickButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    
    
    [self setLoginButtons];
}
- (void)setLoginButtons
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate isLoggedIn]) {
        [toolbar setFrame:CGRectMake(-10, 5, 98, 31)];
        [toolbar addSubview:editAttendingButton];
        NSLog(@"LA TIL ATTENDINGBUTTON");
    }
}


- (void)viewDidUnload
{
    [self.eventDetailsViewController release];
    [self.listOfEvents release];
    [self.filterViewController release];
    [filterButton release];
    [sectListOfEvents release];
    [datePickButton release];
    [editAttendingButton release];
    [toolbar release];
    
    
    //[sectListOfEvents release];
    [listOfEvents release];
    //[filterButton release];
    //[datePickButton release];
    //[editAttendingButton release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (CGPoint) makeGoodPickerPosition
{
    CGPoint topLeft = [eTableView contentOffset];
    topLeft.x = 160;
    topLeft.y = topLeft.y + 310;
    return topLeft;
}

- (void) datePickChanged:(id)sender
{
    BOOL scrollEnabled = [self.eTableView isScrollEnabled];
    [self.eTableView setScrollEnabled:YES];
    [self scrollToDate:[datePicker date] animated:NO];
    [self.eTableView setScrollEnabled:scrollEnabled];
    [self.datePicker setCenter:[self makeGoodPickerPosition]];
}
- (void) hideDatePicker
{
    [datePicker removeFromSuperview];
    [self.datePicker setHidden:YES];
    [self.eTableView setScrollEnabled:YES];
}

- (void)calClicked:(id)sender
{
    if ([self.datePicker isHidden]) {
        [self.eTableView insertSubview:datePicker aboveSubview:self.parentViewController.view];
        [self.datePicker setHidden:NO];
        [self.eTableView setContentOffset:[self.eTableView contentOffset] animated:NO];
        [self.datePicker setCenter:[self makeGoodPickerPosition]];
        [self.eTableView setScrollEnabled:NO];
    } else {
        [self hideDatePicker];
    }
    
}


- (void)comboClicked:(id)sender
{
    [filterViewController release];
    self.filterViewController = [[FilterViewController alloc] initWithNibName:@"FilterView" bundle:nil];
    [self.filterViewController setEventsTableViewController:self];
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.rootController pushViewController:filterViewController animated:YES];
}
-(void)editAttendingClicked:(id)sender
{
    if (editAttending) {
        editAttending = NO;
        [editAttendingButton setImage:[UIImage imageNamed:@"delta_pressed"] forState:UIControlStateNormal];
    } else {
        editAttending = YES;
        [editAttendingButton setImage:[UIImage imageNamed:@"delta"] forState:UIControlStateNormal];
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [self.eTableView reloadData];
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
    return [sectListOfEvents count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [sectListOfEvents objectAtIndex:section];
    return [[dict objectForKey:@"Events"] count];
}

- (void)favoritesClicked:(id)sender event:(id)event
{
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.eTableView];
    NSIndexPath *indexPath = [self.eTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil) {
        NSError *error;
        UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *con = [delegate managedObjectContext];
        
        Event *e = (Event *)[[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row];
        UITableViewCell *cell = [self.eTableView cellForRowAtIndexPath:indexPath];
        UIButton *button = (UIButton *)[cell viewWithTag:3];
        if ([e.favorites intValue] > 0) {
            e.favorites = [NSNumber numberWithInt:0];
            [button setImage:delegate.uncheckedImage forState:UIControlStateNormal];
        }
        else {
            e.favorites = [NSNumber numberWithInt:1];
            [button setImage:delegate.checkedImage forState:UIControlStateNormal];
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
- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier 
{
    UILabel *lblTemp;
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 300, 60) reuseIdentifier:cellIdentifier] autorelease];
    
    //Initialize Label with tag 1.
    lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 290, 20)];
    lblTemp.tag = 1;
    [cell.contentView addSubview:lblTemp];
    [lblTemp release];
    
    //Initialize Label with tag 2.
    lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(15, 27, 185, 13)];
    lblTemp.tag = 2;
    lblTemp.font = [UIFont boldSystemFontOfSize:12];
    lblTemp.textColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:lblTemp];
    [lblTemp release];
    //Initialize attending label
    lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(200, 27, 40, 13)];
    lblTemp.tag = 4;
    lblTemp.font = [UIFont boldSystemFontOfSize:12];
    lblTemp.textColor = [UIColor colorWithRed:0.66f green:0.99f blue:0.65 alpha:1.0f];
    [cell.contentView addSubview:lblTemp];
    [lblTemp release];
    
    
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(260, 5, delegate.checkedImage.size.width*2, delegate.checkedImage.size.height*2);;
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
    
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    dateLabel.text = [NSString stringWithFormat:@"%@ - %@", [delegate.onlyTimeFormat stringFromDate:e.showingTime], e.placeString];
    titleLabel.text = e.title;
    
    if ([e.favorites intValue] > 0) {
        [button setImage:delegate.checkedImage forState:UIControlStateNormal];
    }
    else {
        [button setImage:delegate.uncheckedImage forState:UIControlStateNormal];
    }
    if ([delegate isLoggedIn] && [delegate isInMyEvents:e.id]) {
        UILabel *attendLabel = (UILabel *)[cell viewWithTag:4];
        attendLabel.text = @"Deltar";
        //titleLabel.text = [NSString stringWithFormat:@"%@ - Attending", e.title];
    } else {
        UILabel *attendLabel = (UILabel *)[cell viewWithTag:4];
        attendLabel.text = @"";
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
    




#pragma mark - Table view delegate
/**
 *  Creates a new detailed view of an event
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (![datePicker isHidden]) {
        [self hideDatePicker];
        [self.eTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if (!editAttending) {
        eventDetailsViewController = [[EventDetailsViewController alloc] initWithNibName:@"EventDetailsView" bundle:nil];
        eventDetailsViewController.event = (Event *) [[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row];
        [delegate.rootController pushViewController:eventDetailsViewController animated:YES];
    }
    else {
        [self.eTableView deselectRowAtIndexPath:indexPath animated:NO];
        [delegate flipAttendStatus:[[[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row] id]];
        [self.eTableView reloadData];
    }
}

/**
 * Catches both datepick- and tableview-scrollevents should perhaps only update once every x milliseconds
 */
- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    if (isUsingPicker && sView == pickerView) {
        int pos = (sView.contentOffset.x * [sectListOfEvents count]) / (sView.contentSize.width - pickerOffset*2);//finds the section
        pos = MAX(0, pos);
        pos = MIN([sectListOfEvents count]-1, pos);
        //NSLog(@"scrolling to %i, name %i", pos, [[NSNumber numberWithInteger:sView.tag] intValue]);
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:pos];
        [eTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else if (!isUsingPicker && sView == eTableView) {
        int index = [[NSNumber numberWithUnsignedInteger:[[eTableView indexPathForRowAtPoint:CGPointMake(10, eTableView.contentOffset.y + 40)] section]] intValue];
        //NSLog(@"Pos is %i", index);
        [pickerView setContentOffset:CGPointMake(index*pickerWidth, 0) animated:YES];
        
    }
}
/*- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == pickerView) {
        isUsingPicker = NO;
        NSLog(@"Stopped using picker");
    } else {
        
    }
}*/

/**
 * Sets what view user is scrolling in
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == pickerView) {
        isUsingPicker = YES;
        //NSLog(@"Started picker");
    } else {
        isUsingPicker = NO;
        //NSLog(@"Stopped using picker");
    }
}

@end
