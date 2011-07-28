//
//  StartViewController.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 18.07.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
@class EventsTableViewController;
@class SettingsViewController;

@interface StartViewController : UIViewController <FBSessionDelegate> {
    IBOutlet UIButton *allButton;
    IBOutlet UIButton *artistButton;
    IBOutlet UIButton *favoritesButton;
    IBOutlet UIButton *fbLoginButton;
    IBOutlet EventsTableViewController *eventsTableViewController;
    IBOutlet UIButton *settingsButton;
    IBOutlet SettingsViewController *settingsViewController;
    
}
@property (nonatomic, retain) UIButton *allButton;
@property (nonatomic, retain) UIButton *artistButton;
@property (nonatomic, retain) UIButton *favoritesButton;
@property (nonatomic, retain) EventsTableViewController *eventsTableViewController;
@property (nonatomic, retain) UIButton *fbLoginButton;
@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) SettingsViewController *settingsViewController;

-(void) setLoggedIn:(bool)sessionValid;
- (void)fbDidLogin;
- (void)fbDidLogout;
- (void)fbDidNotLogin:(BOOL)cancelled;
- (void)loginFacebook;
@end
