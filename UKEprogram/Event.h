//
//  Event.h
//  UKEprogram
//
//  Created by UKA-11 Accenture AS on 28.06.11.
//  Copyright (c) 2011 Accenture AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * showingTime;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSNumber * billigId;
@property (nonatomic, retain) NSNumber * free;
@property (nonatomic, retain) NSNumber * canceled;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * lead;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * eventType;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * thumbnail;
@property (nonatomic, retain) NSNumber * ageLimit;
@property (nonatomic, retain) NSNumber * favorites;
@property (nonatomic, retain) NSNumber * lowestPrice;

@end
