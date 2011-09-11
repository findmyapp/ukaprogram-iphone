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
#import "OAuthConsumer.h"
#import "JSON.h"
#import "StartViewController.h"

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
@synthesize loadSpinner;

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
- (void)attendDidChange
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (![delegate isInMyEvents:event.id]) {
        [attendingButton setTitle:@"Sett som deltakende" forState:UIControlStateNormal];
    } else {
        [attendingButton setTitle:@"Ikke delta" forState:UIControlStateNormal];
    }
}

- (void)attendingClicked:(id)sender
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate flipAttendStatus:event.id];
    [self attendDidChange];
}

- (void)pushFriendsView:(id)sender
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.rootController pushViewController:friendsTableViewController animated:YES];
}


- (void)setLoginButtons
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (![delegate isLoggedIn]) {
        [friendsButton setFrame:CGRectMake(8, 220, 250, 37)];
        [friendsButton setTitle:@"Logg inn for å se deltakende venner" forState:UIControlStateNormal];
        [friendsButton addTarget:self action:@selector(fbLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
        [attendingButton setHidden:YES];
    } else {
        [friendsButton setFrame:CGRectMake(8, 220, 167, 37)];
        [friendsButton setHidden:NO];
        if (friendsTableViewController.listOfFriends == nil) {//prevent loading when friends are already loaded
            [friendsTableViewController loadFriends:self];
        }
        [friendsButton addTarget:self action:@selector(pushFriendsView:) forControlEvents:UIControlEventTouchUpInside];
        if (![delegate isLoggedIn]) {
            [attendingButton setHidden:YES];
        } else {
            [self attendDidChange];
            [attendingButton setHidden:NO];
            [attendingButton addTarget:self action:@selector(attendingClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/**
 * Sets the text in labels, and the size of the description and lead label
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Put the loadSpinner into the eventImgView
    loadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadSpinner setCenter:CGPointMake(eventImgView.frame.size.width/2, eventImgView.frame.size.height/2)];
    [eventImgView addSubview:loadSpinner];
    
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
    NSString *dateString = [[NSString alloc] initWithFormat:@"%@ %@", [delegate.onlyDateFormat stringFromDate:event.showingTime], [delegate.onlyTimeFormat stringFromDate:event.showingTime]]; 
    NSString *labelText = [[NSString alloc] initWithFormat:@"%@ %@ %@ %i,-", event.placeString, [delegate getWeekDay:event.showingTime], dateString, [event.lowestPrice intValue]];
    [dateString release];
    [headerLabel setText:labelText];
    [labelText release];
    //find the size of lead and description text
    CGSize constraintSize = CGSizeMake(300.0f, MAXFLOAT);
    CGSize labelSize = [event.text sizeWithFont:textLabel.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat textHeight = labelSize.height;
    labelSize = [event.lead sizeWithFont:leadLabel.font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat leadHeight = labelSize.height;
    //Set the lead and text labels to the size found
    [leadLabel setFrame:CGRectMake(11, 275, 300, leadHeight)];
    [textLabel setFrame:CGRectMake(11, 290 + leadHeight, 300, textHeight)];

    sView = (UIScrollView *) self.view;
    sView.contentSize=CGSizeMake(1, leadHeight + textHeight + 290);//1 is less than width of iphone
    friendsTableViewController = [[FriendsTableViewController alloc] initWithNibName:@"FriendsTableView" bundle:nil];
    
    
    favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favButton.frame = CGRectMake(0, 0, delegate.checkedImage.size.width*2, delegate.checkedImage.size.height*2);
    [favButton addTarget:self action:@selector(favoritesClicked:) forControlEvents:UIControlEventTouchUpInside];
    if ([event.favorites intValue] > 0) {
        [favButton setImage:delegate.checkedImage forState:UIControlStateNormal];
    }
    else {
       [favButton setImage:delegate.uncheckedImage forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:favButton] autorelease];
    
    
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
- (void)fbLoginClicked:(id)sender
{
    NSArray *views = self.navigationController.viewControllers;
    StartViewController *stView = (StartViewController *)[views objectAtIndex:0];
    [stView loginFacebook];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Start spinner
    [loadSpinner startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Check if you should load Image
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //Create file manager
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    //Extract the filename
    NSArray *split = [event.image componentsSeparatedByString:@"/"];
    NSString *fileNameWithoutExtention = [split objectAtIndex:[split count] - 1];
    fileNameWithoutExtention = [fileNameWithoutExtention stringByDeletingPathExtension];
    
    //Find all stored images
    NSArray *listOfImages = [fileMgr contentsOfDirectoryAtPath:docDir error:&error];
    NSString *savedImage;
    
    BOOL doWeNeedToDownLoadImage = YES;
    
    for (id file in listOfImages) {
        if ([file isKindOfClass:[NSString class]] && [[file stringByDeletingPathExtension] isEqualToString:fileNameWithoutExtention] ) {
            doWeNeedToDownLoadImage = NO;
            savedImage = [NSString stringWithFormat:@"%@/%@", docDir, file];
            break;
        }
    }
    
    if (doWeNeedToDownLoadImage) {
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://uka.no/%@", event.image]]]];
        if (img != nil) {
            NSLog(@"IMAGE DOWNLOADED");
            eventImgView.image = img;
            NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@.jpeg",docDir,fileNameWithoutExtention];
            NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(img, 1.0f)];//1.0f = 100% quality
            [data writeToFile:jpegFilePath atomically:YES];
        }
    } else {
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:savedImage]];
        if (img != nil) {
            eventImgView.image = img;
        }
    }
    
    
    [self setLoginButtons];
    [loadSpinner stopAnimating];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [friendsTableViewController release];
    [favButton release];
    [event release];
    [loadSpinner release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
