//
//  EventDetailsViewController.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "Event.h"
#import "UKEprogramAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "Facebook.h"
#import "FriendsTableViewController.h"

/*IBOutlet UILabel *PlaceLabel;
IBOutlet UILabel *DateLabel;
IBOutlet UILabel *leadLabel;
IBOutlet UILabel *textLabel;
IBOutlet UIImage *eventImg;
*/
@implementation EventDetailsViewController
@synthesize headerLabel;
@synthesize leadLabel;
@synthesize textLabel;
@synthesize event;
@synthesize sView;
@synthesize eventImgView;
@synthesize notInUseLabel;
@synthesize attendingButton;
@synthesize friendsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [favButton dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void)attendingClicked:(id)sender
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSLog([delegate.facebook accessToken]);
}

- (void)pushFriendsView:(id)sender
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.rootController pushViewController:friendsTableViewController animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/**
 * Sets the text in labels, and the size of the description and lead label
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:event.title];
    event.lead = [event.lead stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"###"];
    event.lead = [event.lead stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    event.lead = [event.lead stringByReplacingOccurrencesOfString:@"###" withString:@"\r\n\r\n"];
    
    event.text = [event.text stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"###"];
    event.text = [event.text stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    event.text = [event.text stringByReplacingOccurrencesOfString:@"###" withString:@"\r\n\r\n"];
    
    [leadLabel setText:event.lead];
    [textLabel setText:event.text];
    
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *weekday = [delegate.weekDays objectAtIndex:[[delegate.weekDayFormat stringFromDate:event.showingTime] intValue]];
    NSString *dateString = [[NSString alloc] initWithFormat:@"%@ %@", [delegate.onlyDateFormat stringFromDate:event.showingTime], [delegate.onlyTimeFormat stringFromDate:event.showingTime]]; 
    NSString *labelText = [[NSString alloc] initWithFormat:@"%@ %@ %@ %i,-", event.place, weekday, dateString, [event.lowestPrice intValue]];
    [weekday release];
    [dateString release];
    [headerLabel setText:labelText];
    
    //find the size of lead and description text
    CGSize constraintSize = CGSizeMake(300.0f, MAXFLOAT);
    CGSize labelSize = [event.text sizeWithFont:textLabel.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat textHeight = labelSize.height;
    labelSize = [event.lead sizeWithFont:leadLabel.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat leadHeight = labelSize.height;
    //Set the lead and text labels to the size found
    [leadLabel setFrame:CGRectMake(11, 275, 300, leadHeight)];
    [textLabel setFrame:CGRectMake(11, 290 + leadHeight, 300, textHeight)];
    
    //muligens sjekke variabel for om bildet skal lastes ned
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:event.image]]];
    if (img != nil) {
        NSLog(@"Bildet %@ hentet", event.thumbnail);
        eventImgView.image = img;
    }
    
    sView = (UIScrollView *) self.view;
    sView.contentSize=CGSizeMake(1, leadHeight + textHeight + 290);//1 is less than width of iphone
    
    //placeLabel.layer.cornerRadius = 4;
    //dateLabel.layer.cornerRadius = 4;
    notInUseLabel.layer.cornerRadius = 4;
    
    friendsTableViewController = [[FriendsTableViewController alloc] initWithNibName:@"FriendsTableView" bundle:nil];
    
    
    Facebook *facebook = delegate.facebook;
    if (![facebook isSessionValid]) {
        //[friendsButton setTitle:@"Logg inn på face" forState:UIControlStateNormal];
        //[attendingButton setTitle:@"Login with facebook" forState:UIControlStateNormal];
        //[friendsButton addTarget:self action:@selector(facebookLogin:) forControlEvents:UIControlEventTouchUpInside];
        //[attendingButton addTarget:self action:@selector(facebookLogin:) forControlEvents:UIControlEventTouchUpInside];
        [friendsButton setHidden:true];
        [attendingButton setHidden:true];
    } else {
        NSLog(@"DU ER LOGGET INN");
        [friendsButton setTitle:@"Loading..." forState:UIControlStateNormal];
        [attendingButton setTitle:@"Loading..." forState:UIControlStateNormal];
        [friendsTableViewController loadFriends:self];
        [friendsButton addTarget:self action:@selector(pushFriendsView:) forControlEvents:UIControlEventTouchUpInside];
        [attendingButton addTarget:self action:@selector(attendingClicked:) forControlEvents:UIControlEventTouchUpInside];
        //askforfriends...
    }
    
    CGRect ButtonFrame = CGRectMake(0, 0, delegate.checkedImage.size.width*2, delegate.checkedImage.size.height*2);
    favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favButton.frame = ButtonFrame;
    [favButton addTarget:self action:@selector(favoritesClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ([event.favorites intValue] > 0) {
        [favButton setImage:delegate.checkedImage forState:UIControlStateNormal];
    }
    else {
       [favButton setImage:delegate.uncheckedImage forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:favButton];
    
    //[textLabel setText:[event.showingTime 
}

- (void)favoritesClicked:(id)sender
{
    NSError *error;
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *con = [delegate managedObjectContext];
    if ([event.favorites intValue] > 0) {
        event.favorites = [NSNumber numberWithInt:0];
        [favButton setImage:delegate.uncheckedImage forState:UIControlStateNormal];
    }
    else {
        event.favorites = [NSNumber numberWithInt:1];
        [favButton setImage:delegate.checkedImage forState:UIControlStateNormal];
    }
    if (![con save:&error]) {
        NSLog(@"Lagring av %@ feilet", event.title);
    } else {
        NSLog(@"Lagret event %@", event.title);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [friendsTableViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
