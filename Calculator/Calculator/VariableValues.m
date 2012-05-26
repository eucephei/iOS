//
//  VariableValues.m
//  Calculator
//
//  Created by ace on 23/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VariableValues.h"

@implementation VariableValues

@synthesize dict        = _dict;
@synthesize dictKeys    = _dictKeys;

- (NSMutableDictionary *) dict
{
    if (!_dict) {        
        _dict = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                 [NSNumber numberWithDouble:M_LOG2E], @"a", 
                 [NSNumber numberWithDouble:M_PI_2], @"b", 
                 [NSNumber numberWithDouble:M_E], @"x", nil];
    }
    return _dict;
}

- (NSSet *) dictKeys
{
    return [NSSet setWithArray:[self.dict allKeys]];
}

@end
