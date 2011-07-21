//
//  FriendsTableViewController.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 21.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "Event.h"
#import "UKEprogramAppDelegate.h"
#import "EventDetailsViewController.h"

@implementation FriendsTableViewController

@synthesize listOfFriends;
@synthesize friendTableView;
@synthesize friendCountLabel;

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
-(void) loadFriends:(EventDetailsViewController *) controller
{
    eventDetailsViewController = controller;
    Event *event = eventDetailsViewController.event;
    [self setTitle:[NSString stringWithFormat:@"Friends at %@", event.title]];
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
}
    

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [friendCountLabel setText:@"Loading..."];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
