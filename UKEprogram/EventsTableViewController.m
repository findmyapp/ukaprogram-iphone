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
@synthesize filterViewController;
@synthesize eventsTableView;
@synthesize pickerView;
UIButton *filterButton;
UIButton *editAttendingButton;
UIToolbar *toolbar;
BOOL editAttending;
//int days;
NSMutableArray *sectListOfEvents;
static int secondsInDay = 86400;

static int dateBoxOffset = 125;
static int dateBoxWidth = 70;
static int dateBoxTextWidth =66;
static int dateBoxSeparatorWidth = 2;

static int eTableScrollIndex = 0;
NSDate *lastScrollUpdate;

bool isUsingPicker = NO;


/**
 * Create labels for date-picking horizontal scrollview at top
 */


-(void)createPickerDates
{
    //place background image
    UIImageView *bildeView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    UIImage *backImg = [UIImage imageNamed:@"datePickerBackground.png"];
    [bildeView2 setImage:backImg];
    [bildeView2 setAlpha:0.35];
    [self.view addSubview:bildeView2];
    [bildeView2 release];
    
    
    UKEprogramAppDelegate *del = [[UIApplication sharedApplication] delegate];
    NSDateFormatter *onlyDateFormat = del.onlyDateFormat;
    
    for(UIView *subview in [pickerView subviews]) {
        [subview removeFromSuperview];
    }
    CGRect dateBoxRect = CGRectMake(dateBoxOffset, 2, dateBoxWidth, pickerView.bounds.size.height - 2); // width = 70
    CGRect dateBoxTextRect = CGRectMake(dateBoxSeparatorWidth, 2, dateBoxTextWidth, pickerView.bounds.size.height - 2); // width = 66
    CGRect dateBoxSeparatorRect = CGRectMake(0, 2, dateBoxSeparatorWidth, pickerView.bounds.size.height - 2); //width = 2
    int i;
    for(i = 0; i < sectListOfEvents.count; i++) {
        Event *e = [[[sectListOfEvents objectAtIndex:i] objectForKey:@"Events"] objectAtIndex:0];
        //Init colorlabelLeft (separator)
        UILabel *colorLblLeft = [[UILabel alloc] initWithFrame:dateBoxSeparatorRect];
        colorLblLeft.backgroundColor = [UIColor clearColor];
        //[UIColor colorWithRed:0.490 green:0.647 blue:0.682 alpha:1.0]; iPhone Grå-blå
        //[UIColor colorWithRed:0.6 green:0.113 blue:0.125 alpha:0.5]; UKA-rød
        
        //Init colorlabelRight (separator)
        dateBoxSeparatorRect.origin.x = (dateBoxWidth - dateBoxSeparatorWidth);
        UILabel *colorLblRight = [[UILabel alloc] initWithFrame:dateBoxSeparatorRect];
        colorLblRight.backgroundColor = [UIColor clearColor];
        dateBoxSeparatorRect.origin.x = 0;
        
        //Init dateBox
        UIView *dateBox = [[UIView alloc] initWithFrame:dateBoxRect];
        dateBox.backgroundColor = [UIColor clearColor];
        
        //Add Textlabel
        UILabel *lbl = [[UILabel alloc] initWithFrame:dateBoxTextRect];
        lbl.font = [UIFont systemFontOfSize:13];
        lbl.textColor = [UIColor colorWithRed:0.6 green:0.113 blue:0.125 alpha:1.0];
        lbl.backgroundColor = [UIColor colorWithRed:0.490 green:0.647 blue:0.682 alpha:0.2];
        lbl.textAlignment = UITextAlignmentCenter;
        [lbl setNumberOfLines:2];
        [lbl setText:[NSString stringWithFormat:@"%@\n%@", [del getWeekDay:e.showingTime], [onlyDateFormat stringFromDate:e.showingTime]]];
        
        //First, add colorLblLeft...
        [dateBox addSubview:colorLblLeft];
        //..then add textLbl...
        [dateBox addSubview:lbl];
        //..and  add colorLbRight...
        [dateBox addSubview:colorLblRight];
        
        [pickerView addSubview:dateBox];
        
        //Change the startposition of dateBoxRect before the next box is drawn
        dateBoxRect.origin.x += dateBoxWidth;
    }
    pickerView.contentSize = CGSizeMake(2 * dateBoxOffset + ( i * dateBoxWidth), 1);
    
    [self.view addSubview:pickerView];
    //place transparent image
    UIImageView *bildeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42)];
    UIImage *transImg = [UIImage imageNamed:@"datePickerTransparentLayer.png"];
    [bildeView setImage:transImg];
    bildeView.alpha = 0.6;
    [self.view addSubview:bildeView];
    [bildeView release];
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
    }
    [self createPickerDates];
    NSLog(@"Table updatet");
    [eventsTableView reloadData];
    
    
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
        [eventsTableView scrollToRowAtIndexPath:scrollPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
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
    
    lastScrollUpdate = [NSDate date];
    [lastScrollUpdate retain];
    
    [eventsTableView setDelegate:self];
    [eventsTableView setDataSource:self];
    [pickerView setDelegate:self];
    
    editAttending = NO;
    listOfEvents = [[NSMutableArray alloc] init];

    self.navigationItem.title = @"Program";
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    filterButton.frame = CGRectMake(0, 0, 36, 31);
    filterButton.tag = 3;
    [filterButton addTarget:self action:@selector(comboClicked:) forControlEvents:UIControlEventTouchUpInside];

    //[datePickButton setTitle:@"Dato" forState:UIControlStateNormal];
    [filterButton setImage:[UIImage imageNamed:@"choose_button"] forState:UIControlStateNormal];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 5, 36, 31)];
    
    editAttendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editAttendingButton.frame = CGRectMake(36, 0, 36, 31);
    //[editAttendingButton setTitle:@"edit" forState:UIControlStateNormal];
    [editAttendingButton setImage:[UIImage imageNamed:@"delta_pressed"] forState:UIControlStateNormal];
    [editAttendingButton addTarget:self action:@selector(editAttendingClicked:) forControlEvents:UIControlEventTouchUpInside];
    editAttendingButton.tag = 5;
    [editAttendingButton retain];
    
    [toolbar addSubview:filterButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    
    
    [self setLoginButtons];
}
- (void)setLoginButtons
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate isLoggedIn]) {
        [toolbar setFrame:CGRectMake(0, 5, 72, 31)];
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
    [editAttendingButton release];
    [toolbar release];
    [listOfEvents release];
    [lastScrollUpdate release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (CGPoint) makeGoodPickerPosition
{
    CGPoint topLeft = [eventsTableView contentOffset];
    topLeft.x = 160;
    topLeft.y = topLeft.y + 310;
    return topLeft;
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
    [eventsTableView reloadData];
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

- (void)favoritesClicked:(id)sender event:(id)event
{
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:eventsTableView];
    NSIndexPath *indexPath = [eventsTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil) {
        NSError *error;
        UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *con = [delegate managedObjectContext];
        
        Event *e = (Event *)[[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row];
        UITableViewCell *cell = [eventsTableView cellForRowAtIndexPath:indexPath];
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

#define CELL_ROW_HEIGHT 50

/**
 *  returns a view for displaying each event in the table
 */
- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier 
{
    UILabel *lblTemp;
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 300, CELL_ROW_HEIGHT) reuseIdentifier:cellIdentifier] autorelease];
    
    //Initialize Label with tag 1.
    lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 290, 20)];
    lblTemp.tag = 1;
    [cell.contentView addSubview:lblTemp];
    [lblTemp release];
    
    //Initialize Label with tag 2.
    lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(12, 27, 187, 13)];
    lblTemp.tag = 2;
    lblTemp.font = [UIFont boldSystemFontOfSize:12];
    lblTemp.textColor = [UIColor colorWithRed:0.6 green:0.113 blue:0.125 alpha:0.7];
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *containerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 21)] autorelease];
    UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 200, 21)] autorelease];
    //UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIImage *backImg = [UIImage imageNamed:@"tableRowHeader.png"];
    if (backImg == nil) {
        NSLog(@"Cant find image!!!!!!!!!!");
    }
    [containerView setImage:backImg];
    
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.backgroundColor = [UIColor clearColor];
    
    [containerView addSubview:headerLabel];
    
    return containerView;
}


/**
 *  Displays events in the table
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

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
    dateLabel.text = [NSString stringWithFormat:@"%@ - kl.%@", e.placeString, [delegate.onlyTimeFormat stringFromDate:e.showingTime]];
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
    if (!editAttending) {
        eventDetailsViewController = [[EventDetailsViewController alloc] initWithNibName:@"EventDetailsView" bundle:nil];
        eventDetailsViewController.event = (Event *) [[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row];
        [delegate.rootController pushViewController:eventDetailsViewController animated:YES];
    }
    else {
        [eventsTableView deselectRowAtIndexPath:indexPath animated:NO];
        [delegate flipAttendStatus:[[[[sectListOfEvents objectAtIndex:indexPath.section] objectForKey:@"Events"] objectAtIndex:indexPath.row] id]];
        [eventsTableView reloadData];
    }
}

-(void)snapToPosition:(UIScrollView *)sView
{
    if (sView == pickerView){
        int pos = ((sView.contentOffset.x + dateBoxWidth/2) * [sectListOfEvents count]) / (sView.contentSize.width - dateBoxOffset * 2);
        pos = MAX(0, pos);
        pos = MIN([sectListOfEvents count]-1, pos);
        [pickerView setContentOffset:CGPointMake((pos * dateBoxWidth), 0) animated:YES];
    } else if (sView == eventsTableView) {
        NSIndexPath *path = [eventsTableView indexPathForRowAtPoint:CGPointMake(10, sView.contentOffset.y + 22)];
        if (path) {
            eTableScrollIndex = [[NSNumber numberWithUnsignedInteger:[path section]] intValue];
            [pickerView setContentOffset:CGPointMake((eTableScrollIndex * dateBoxWidth), 0) animated:YES];
        } 
    }
}

/**
 * Catches both datepick- and tableview-scrollevents
 */
- (void)scrollViewDidScroll:(UIScrollView *)sView
{
    NSTimeInterval timePassed_ms = [lastScrollUpdate timeIntervalSinceNow] * -1000.0;
    if (timePassed_ms > 300) {
        [lastScrollUpdate release];
        lastScrollUpdate = [NSDate date];
        [lastScrollUpdate retain];
        if (isUsingPicker && sView == pickerView) {
            int pos = ((sView.contentOffset.x + dateBoxWidth/2) * [sectListOfEvents count]) / (sView.contentSize.width - dateBoxOffset * 2);//finds the section
            pos = MAX(0, pos);
            pos = MIN([sectListOfEvents count]-1, pos);
            NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:pos];
            [eventsTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else if (!isUsingPicker && sView == eventsTableView) {
            [self snapToPosition:sView];
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self snapToPosition:scrollView];
    }
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self snapToPosition:scrollView];
}

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
