//
//  SettingsViewController.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 22.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "SettingsViewController.h"
#import "JSON.h"
#import "UKEprogramAppDelegate.h"
#import "OAuthConsumer.h"

@implementation SettingsViewController

@synthesize settingsTableView;
NSArray *settingsName;
NSArray *settingsRealName;
NSArray *settingsValue;
UIImage *currentValue;
NSMutableArray *selectedValue;
BOOL loading;


- (NSNumber *)mapValue:(NSString *)sValue
{
    if ([sValue isEqualToString:@"ANYONE"]) {
        return [NSNumber numberWithInt:0];
    }
    else if ([sValue isEqualToString:@"FRIENDS"]) {
        return [NSNumber numberWithInt:1];
    }
    else if ([sValue isEqualToString:@"ONLY_ME"]) {
        return [NSNumber numberWithInt:2];
    }
    else {
        return [NSNumber numberWithInt:3];
    }
}
/*
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
    NSLog(@"Connection closed");
    NSString *responseString = [[NSString alloc] initWithData:responseData  encoding:NSASCIIStringEncoding];
    NSLog(@"recieved %@", responseString);
    [responseData release];
    NSDictionary *settings = [responseString JSONValue];

    [selectedValue replaceObjectAtIndex:0 withObject:[self mapValue:[settings valueForKey:@"positionPrivacySetting"]]];
    [selectedValue replaceObjectAtIndex:1 withObject:[self mapValue:[settings valueForKey:@"eventsPrivacySetting"]]];
    [selectedValue replaceObjectAtIndex:2 withObject:[self mapValue:[settings valueForKey:@"moneyPrivacySetting"]]];
    [selectedValue replaceObjectAtIndex:3 withObject:[self mapValue:[settings valueForKey:@"mediaPrivacySetting"]]];
    
    loading = NO;
    [settingsTableView reloadData];
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/*
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
    NSLog(@"DIDRECEIVERESPONSE");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
    NSLog(@"DIDRECEIVEDATA");
}

- (void)connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    //self.twitterLabel.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
    //[myTableView setNeedsDisplay];
    NSLog(@"DIDFAILWITHERROR");
}
*/
/**
 * Request to uka backend to retrieve all events
 */

- (void)dealloc
{
    [super dealloc];
    [settingsName dealloc];
    [settingsValue dealloc];
    [currentValue dealloc];
    [settingsRealName dealloc];
    [selectedValue dealloc];
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) requestTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    NSLog(@"unsuccessfull finish %@", error);
}

- (void) requestTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSLog(@"successfull finish");
    NSString *responseString = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    NSLog(@"recieved %@", responseString);
    NSDictionary *settings = [responseString JSONValue];
    
    [selectedValue replaceObjectAtIndex:0 withObject:[self mapValue:[settings valueForKey:@"positionPrivacySetting"]]];
    [selectedValue replaceObjectAtIndex:1 withObject:[self mapValue:[settings valueForKey:@"eventsPrivacySetting"]]];
    [selectedValue replaceObjectAtIndex:2 withObject:[self mapValue:[settings valueForKey:@"moneyPrivacySetting"]]];
    [selectedValue replaceObjectAtIndex:3 withObject:[self mapValue:[settings valueForKey:@"mediaPrivacySetting"]]];
    
    loading = NO;
    [settingsTableView reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    settingsName = [[NSArray alloc] initWithObjects:@"Deling av posisjonsdata",@"Deling av arrangementsdata",@"Deling av pengebruk",@"Deling av media", nil];
    settingsRealName = [[NSArray alloc] initWithObjects:@"positionPrivacySetting",@"eventsPrivacySetting",@"moneyPrivacySetting",@"mediaPrivacySetting", nil];
    settingsValue = [[NSArray alloc] initWithObjects:@"Alle",@"Venner",@"Bare meg", nil];
    currentValue = [UIImage imageNamed:@"currentValue"];
    selectedValue = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:0], [NSNumber numberWithInt:2], [NSNumber numberWithInt:1], nil];
    loading = YES;
    self.navigationItem.title = @"Innstillinger for UKApps";
    
    //OAuth
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURL *url = [NSURL URLWithString:@"http://findmyapp.net/findmyapp/users/me/privacy"];
    //NSURL *url = [NSURL URLWithString:@"http://129.241.223.245:8080/findmyapp/cashless/friends"];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:delegate.consumer token:nil realm:nil signatureProvider:nil];//should default sha1
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    OARequestParameter *token = [[OARequestParameter alloc] initWithName:@"token" value:delegate.formattedToken];
    NSArray *params = [NSArray arrayWithObjects:token, nil];
    [request setParameters:params];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestTicket:didFinishWithData:) didFailSelector:@selector(requestTicket:didFailWithError:)];
    
    /*
    NSString *eventsApiUrl = [NSString stringWithFormat: @"http://findmyapp.net/findmyapp/users/1/privacy"];
    responseData = [[NSMutableData data] retain];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:eventsApiUrl]];
    NSLog(@"Opening connection");
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    */
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UKEprogramAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [self.settingsTableView deselectRowAtIndexPath:indexPath animated:NO];
    if (!loading && [[selectedValue objectAtIndex:indexPath.section] intValue] != [[NSNumber numberWithUnsignedInteger:indexPath.row] intValue]) {
        loading = YES;
        [tableView reloadData];
        
        
        NSURL *url = [NSURL URLWithString:@"http://findmyapp.net/findmyapp/users/me/privacy"];
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url consumer:delegate.consumer token:nil realm:nil signatureProvider:nil];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSNumber *num = [NSNumber numberWithInt:([[NSNumber numberWithUnsignedInteger:indexPath.row] intValue] + 1)];
        //NSNumber *num = [NSNumber numberWithUnsignedInteger:indexPath.row];
        NSLog(@"Posting %@: %i", [settingsRealName objectAtIndex:indexPath.section], [num intValue]);
        OARequestParameter *postData = [[OARequestParameter alloc] initWithName:[settingsRealName objectAtIndex:indexPath.section] value:[num stringValue]];
        OARequestParameter *token = [[OARequestParameter alloc] initWithName:@"token" value:delegate.formattedToken];
        NSArray *params = [NSArray arrayWithObjects:postData, token, nil];
        [request setParameters:params];
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];
        [fetcher fetchDataWithRequest:request delegate:self didFinishSelector:@selector(requestTicket:didFinishWithData:) didFailSelector:@selector(requestTicket:didFailWithError:)];
    }
}

- (NSString *)tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section {
    
    return [settingsName objectAtIndex:section];
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier 
{
    CGRect CellFrame = CGRectMake(0, 0, 300, 35);
    CGRect LabelFrame = CGRectMake(10, 5, 290, 30);
    CGRect viewFrame = CGRectMake(250, 10, 30, 30);
    UILabel *lblTemp;
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame] autorelease];
    UIImageView *tempView;
    //Initialize Label with tag 1.
    lblTemp = [[UILabel alloc] initWithFrame:LabelFrame];
    lblTemp.tag = 1;
    [cell.contentView addSubview:lblTemp];
    [lblTemp release];
    
    tempView = [[UIImageView alloc] initWithFrame:viewFrame];
    tempView.tag = 2;
    [cell.contentView addSubview:tempView];
    [tempView release];
    return cell;
}

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
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    UIImageView *view = (UIImageView *)[cell viewWithTag:2];
    
    
    [textLabel setText:[settingsValue objectAtIndex:indexPath.row]];
    if (loading) {
        
    }
    else if ([[selectedValue objectAtIndex:indexPath.section] isEqualToNumber:[NSNumber numberWithUnsignedInteger:indexPath.row ]]) {
        [view setImage:currentValue];
    }
    
    
    
    return cell;
}

@end
