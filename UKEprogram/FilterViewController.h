//
//  FilterViewController.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 20.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventsTableViewController;

@interface FilterViewController : UIViewController {
    IBOutlet UIButton *alleButton;
    IBOutlet UIButton *konsertButton;
    IBOutlet UIButton *revyButton;
    IBOutlet UIButton *kursButton;
    IBOutlet UIButton *festButton;
    IBOutlet UIButton *favorittButton;
    EventsTableViewController *eventsTableViewController;
}

@property (retain) IBOutlet UIButton *alleButton;
@property (retain) IBOutlet UIButton *konsertButton;
@property (retain) IBOutlet UIButton *revyButton;
@property (retain) IBOutlet UIButton *kursButton;
@property (retain) IBOutlet UIButton *festButton;
@property (retain) IBOutlet UIButton *favorittButton;
@property (nonatomic, retain) EventsTableViewController *eventsTableViewController;


@end
