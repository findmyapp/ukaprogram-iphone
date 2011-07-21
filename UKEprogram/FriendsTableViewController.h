//
//  FriendsTableViewController.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 21.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventDetailsViewController;
@interface FriendsTableViewController : UIViewController {
    IBOutlet UILabel *friendCountLabel;
    IBOutlet UITableView *friendTableView;
    NSArray *listOfFriends;
    NSMutableData *responseData;
    EventDetailsViewController *eventDetailsViewController;
}

@property (nonatomic, retain) NSArray *listOfFriends;
@property (nonatomic, retain) UILabel *friendCountLabel;
@property (nonatomic, retain) UITableView *friendTableView;


-(void) loadFriends:(EventDetailsViewController *) controller;
@end
