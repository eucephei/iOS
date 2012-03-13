//
//  FlagAnnotationView.m
//  USATable
//
//  Created by ace on 11/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// originally going to load via UINib usage, but then fell back to hardcoding. 

#import "FlagAnnotationView.h"

@implementation FlagAnnotationView

@synthesize flagImage;

+ (NSString*) identifier 
{
	return NSStringFromClass([self class]);
}

+ (id) flagAnnotationViewForMapView:(MKMapView*)mapView 
{
	MKAnnotationView* view = [mapView dequeueReusableAnnotationViewWithIdentifier:[self identifier]];
	if ( view != nil ) {
		return view;
	}
    
	return [[[[self class] alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)dealloc
{
	[flagImage release];
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame 
{
	UIImage* flagpole = [UIImage imageNamed:@"flagpole.png"];
    
	// redefine our frame to fit the flagpole image
	frame = (CGRect) { .size = flagpole.size };
	self = [super initWithFrame:frame];
	if ( self != nil ) {
		self.backgroundColor = [UIColor clearColor];
		UIImageView* flagpoleView = [[UIImageView alloc] initWithImage:flagpole];
		[self addSubview:flagpoleView];
		[flagpoleView release];
		
		// values taken from layout in XIB
		CGRect flagRect = 
            { .origin.x = 15, .origin.y = 14, .size.width = 53, .size.height = 45, };
		UIImageView* flagView = [[UIImageView alloc] initWithFrame:flagRect];
		flagView.backgroundColor = [UIColor clearColor];
		flagView.contentMode = UIViewContentModeTopLeft;
		[self addSubview:flagView];
		self.flagImage = flagView;
		[flagView release];
		
		// approximate offset to put bottom of flagpole at coordinate
		self.centerOffset = (CGPoint) { .x = 25, .y = -31 };
		
		self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	}
	return self;
}

- (NSString*) reuseIdentifier 
{
	return [[self class] identifier];
}

- (BOOL) canShowCallout 
{
	return YES;
}

@end
