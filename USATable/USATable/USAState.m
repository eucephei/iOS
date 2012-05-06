//
//  USAState.m
//  USATable
//
//  Created by ace on 11/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "USAState.h"

@interface USAState ()
+ (NSString*) transformStateNameForImage:(NSString*)name;
@end

@implementation USAState

@synthesize name;
@synthesize abbreviation;
@synthesize capital;
@synthesize populousCity;
@synthesize area;
@synthesize date;
@synthesize population;
@synthesize coordinate;

- (void) dealloc 
{
	self.name = nil;
	self.abbreviation = nil;
	self.capital = nil;
	self.populousCity = nil;
	self.area = nil;
	self.date = nil;
	self.population = nil;
	
	[super dealloc];
}

- (id) initWithDictionary:(NSDictionary*)dict 
{
	self = [super init];
	if ( self == nil ) {
		return nil;
	}
	
	self.name = [dict valueForKey:@"name"];
	self.abbreviation = [dict valueForKey:@"abbreviation"];
	self.area = [dict valueForKey:@"area"];
	self.capital = [dict valueForKey:@"capital"];
	self.date = [dict valueForKey:@"date"];
	self.population = [dict valueForKey:@"population"];
	self.populousCity = [dict valueForKey:@"populousCity"];
	self.coordinate = CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"] doubleValue], [[dict valueForKey:@"longitude"] doubleValue]);
	
	return self;
}

+ (NSArray*) sortedStates 
{
	static NSArray* gStates = nil;
	if ( gStates == nil ) {
		NSArray* stateDicts = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"states" ofType:@"plist"]];
		NSMutableArray* states = [NSMutableArray array];
		for ( NSDictionary* stateDict in stateDicts ) {
			USAState* state = [[USAState alloc] initWithDictionary:stateDict];
			[states addObject:state];
            [state release];
		}
		NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
		gStates = [[states sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] retain];
	}
	
	return gStates;
}

+ (NSString*) transformStateNameForImage:(NSString*)name 
{
	NSString* baseName = [name lowercaseString];
	baseName = [baseName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	return baseName;
}

+ (NSString*) pathForSmallImage:(NSDictionary*)state 
{
	NSString* baseName = [self transformStateNameForImage:[state valueForKey:@"name"]];
	NSString* path = [[NSBundle mainBundle] pathForResource:[baseName stringByAppendingString:@"-50"] ofType:@"png"];
	return path;
}

- (NSString*) pathForLargeImage 
{
	NSString* baseName = [[self class] transformStateNameForImage:self.name];
	NSString* path = [[NSBundle mainBundle] pathForResource:[baseName stringByAppendingString:@"-200"] ofType:@"png"];
	return path;
}

- (UIImage*) smallImage 
{
	NSString* baseName = [[self class] transformStateNameForImage:self.name];
	return [UIImage imageNamed:[baseName stringByAppendingString:@"-50.png"]];
}


- (NSString*) description 
{
	return [NSString stringWithFormat:@"%@ : %@", [self class], self.name];
}

#pragma mark - MKAnnotation

/*
// coordinate already handled directly by our property
- (CLLocationCoordinate2D) coordinate 
{	
}
 */

- (NSString*) title 
{
	return self.capital;
}

- (NSString*) subtitle 
{
	return self.name;
}

@end
