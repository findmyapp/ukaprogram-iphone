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

@interface EventsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate> {
    IBOutlet UITableView *eventsTableView;
    IBOutlet UIScrollView *pickerView;
    NSMutableArray *listOfEvents;
    EventDetailsViewController *eventDetailsViewController;
    
    FilterViewController *filterViewController;
}
@property (nonatomic, retain) UIScrollView *pickerView;
@property (nonatomic, retain) NSMutableArray *listOfEvents;
@property (nonatomic, retain) EventDetailsViewController *eventDetailsViewController;
@property (nonatomic, retain) FilterViewController *filterViewController;
@property (nonatomic, retain) UITableView *eventsTableView;

-(void) showAllEvents;
-(void) showFavoriteEvents;
-(void) showKonsertEvents;
-(void) showRevyEvents;
-(void) showKursEvents;
-(void) showFestEvents;
-(void) scrollToDate:(NSDate *)date animated:(BOOL)animated;
-(void) setLoginButtons;
@end
