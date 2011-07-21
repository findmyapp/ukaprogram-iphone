//
//  UKEprogramAppDelegate.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright 2011 Accenture AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"


@interface UKEprogramAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate> {
    IBOutlet UINavigationController * rootController;
    NSMutableData *responseData;
    NSDateFormatter *dateFormat;
    NSDateFormatter *weekDayFormat;
    NSDateFormatter *onlyDateFormat;
    NSDateFormatter *onlyTimeFormat;
    NSArray *weekDays;
    UIImage *checkedImage;
    UIImage *uncheckedImage;
    Facebook *facebook;
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

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end