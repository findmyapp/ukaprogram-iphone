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

    

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [friendCountLabel setText:@"Loading..."];
    listOfFriends = [[NSArray alloc] init];
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


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [connection release];
    NSLog(@"Connection closed");
    NSString *responseString = [[NSString alloc] initWithData:responseData  encoding:NSASCIIStringEncoding];
    [responseData release];
    NSDictionary *results = [responseString JSONValue];
    [responseString release];
    
    
    [friendTableView reloadData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
    NSLog(@"DIDRECEIVERESPONSE");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
    NSLog(@"DIDRECEIVEDATA");
}

- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    NSLog(@"DIDFAILWITHERROR");
}

-(void) loadFriends:(EventDetailsViewController *) controller
{
    eventDetailsViewController = controller;
    Event *event = eventDetailsViewController.event;
    [self setTitle:[NSString stringWithFormat:@"Friends at %@", event.title]];
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    
    NSString *eventsApiUrl = [NSString stringWithFormat: @"http://findmyapp.net/findmyapp/program/uka11/events"];
    responseData = [[NSMutableData data] retain];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:eventsApiUrl]];
    
    NSLog(@"Opening connection");
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    NSString *cellValue = [listOfFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.friendTableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
