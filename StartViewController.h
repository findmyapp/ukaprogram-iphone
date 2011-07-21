//
//  StartViewController.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 18.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventsTableViewController;

@interface StartViewController : UIViewController {
    IBOutlet UIButton *allButton;
    IBOutlet UIButton *artistButton;
    IBOutlet UIButton *favoritesButton;
    IBOutlet UIButton *fbLoginButton;
    IBOutlet EventsTableViewController *eventsTableViewController;
    
}
@property (nonatomic, retain) UIButton *allButton;
@property (nonatomic, retain) UIButton *artistButton;
@property (nonatomic, retain) UIButton *favoritesButton;
@property (nonatomic, retain) EventsTableViewController *eventsTableViewController;
@property (nonatomic, retain) UIButton *fbLoginButton;

-(void) setLoggedIn:(bool)sessionValid;
@end
