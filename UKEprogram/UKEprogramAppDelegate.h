//
//  UKEprogramAppDelegate.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
@class OAConsumer;

@interface UKEprogramAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UINavigationController * rootController;
    NSMutableData *eventResponseData;
    //NSMutableData *loginResponseData;
    NSDateFormatter *dateFormat;
    NSDateFormatter *weekDayFormat;
    NSDateFormatter *onlyDateFormat;
    NSDateFormatter *onlyTimeFormat;
    NSArray *weekDays;
    UIImage *checkedImage;
    UIImage *uncheckedImage;
    Facebook *facebook;
    //NSURLConnection *eventFillConnection;
    //NSURLConnection *loginConnection;
    NSString *formattedToken;
    OAConsumer *consumer;
    NSMutableArray *myEvents;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController * rootController;
@property (retain) NSDateFormatter *dateFormat;
@property (retain) NSDateFormatter *weekDayFormat;
@property (retain) NSDateFormatter *onlyDateFormat;
@property (retain) NSDateFormatter *onlyTimeFormat;
@property (retain) NSArray *weekDays;
@property (retain) UIImage *checkedImage;
@property (retain) UIImage *uncheckedImage;
@property (nonatomic, retain) Facebook *facebook;
@property (retain) NSString *formattedToken;
@property (retain) OAConsumer *consumer;
@property (retain) NSMutableArray *myEvents;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (UIColor *) getColorForEventCategory:(NSString *)category;
- (void)loginBackend;
- (BOOL)isInMyEvents:(NSNumber *)eid;
- (void)flipAttendStatus:(NSNumber *)eventId;
- (BOOL)isLoggedIn;
- (NSString *)getWeekDay:(NSDate *)date;
@end