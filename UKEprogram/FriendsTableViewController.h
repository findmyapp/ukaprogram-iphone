//
//  FriendsTableViewController.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 21.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventDetailsViewController;
@interface FriendsTableViewController : UIViewController <UITableViewDelegate> {
    IBOutlet UITableView *friendsTableView;
    NSMutableArray *listOfFriends;
    NSMutableData *responseData;
    EventDetailsViewController *eventDetailsViewController;
}

@property (nonatomic, retain) NSMutableArray *listOfFriends;
@property (nonatomic, retain) UITableView *friendsTableView;


-(void) loadFriends:(EventDetailsViewController *) controller;
@end
