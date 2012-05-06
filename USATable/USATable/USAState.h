//
//  USAState.h
//  USATable
//
//  Created by ace on 11/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface USAState : NSObject <MKAnnotation> 

- (id) initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* abbreviation;
@property (nonatomic, copy) NSString* capital;
@property (nonatomic, copy) NSString* populousCity;
@property (nonatomic, retain) NSNumber* area;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSNumber* population;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

+ (NSArray*) sortedStates;
+ (NSString*) pathForSmallImage:(NSDictionary*)state;

- (NSString*) pathForLargeImage;
- (UIImage*) smallImage;

@end
