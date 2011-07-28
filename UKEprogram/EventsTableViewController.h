//
//  EventsTableViewController.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EventDetailsViewController;
@class FilterViewController;

@interface EventsTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *eventsTableView;
    IBOutlet UIDatePicker *datePicker;
    NSMutableArray *listOfEvents;
    EventDetailsViewController *eventDetailsViewController;
    
    FilterViewController *filterViewController;
}
@property (nonatomic, retain) NSMutableArray *listOfEvents;
@property (nonatomic, retain) EventDetailsViewController *eventDetailsViewController;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) FilterViewController *filterViewController;


-(void) showAllEvents;
-(void) showFavoriteEvents;
-(void) showKonsertEvents;
-(void) showRevyEvents;
-(void) showKursEvents;
-(void) showFestEvents;
-(void) scrollToDate:(NSDate *)date animated:(BOOL)animated;
-(void) setLoginButtons;
@end
