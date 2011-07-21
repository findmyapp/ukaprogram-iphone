//
//  FilterViewController.m
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 20.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import "FilterViewController.h"
#import "EventsTableViewController.h"
#import "UKEprogramAppDelegate.h"

@implementation FilterViewController

@synthesize alleButton;
@synthesize konsertButton;
@synthesize revyButton;
@synthesize kursButton;
@synthesize festButton;
@synthesize favorittButton;
@synthesize eventsTableViewController;

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
- (void) alleClicked:(id)sender
{
    [self.eventsTableViewController showAllEvents];
    [[self retain] autorelease];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) konsertClicked:(id)sender
{
    [self.eventsTableViewController showKonsertEvents];
    [[self retain] autorelease];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) revyClicked:(id)sender
{
    [self.eventsTableViewController showRevyEvents];
    [[self retain] autorelease];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) kursClicked:(id)sender
{
    [self.eventsTableViewController showKursEvents];
    [[self retain] autorelease];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) festClicked:(id)sender
{
    [self.eventsTableViewController showFestEvents];
    [[self retain] autorelease];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) favorittClicked:(id)sender
{
    [self.eventsTableViewController showFavoriteEvents];
    [[self retain] autorelease];
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Velg eventtype"];
    [alleButton addTarget:self action:@selector(alleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [konsertButton addTarget:self action:@selector(konsertClicked:) forControlEvents:UIControlEventTouchUpInside];
    [revyButton addTarget:self action:@selector(revyClicked:) forControlEvents:UIControlEventTouchUpInside];
    [kursButton addTarget:self action:@selector(kursClicked:) forControlEvents:UIControlEventTouchUpInside];
    [festButton addTarget:self action:@selector(festClicked:) forControlEvents:UIControlEventTouchUpInside];
    [favorittButton addTarget:self action:@selector(favorittClicked:) forControlEvents:UIControlEventTouchUpInside];
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
