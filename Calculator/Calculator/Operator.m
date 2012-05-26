//
//  Operator.m
//  Calculator
//
//  Created by ace on 24/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Operator.h"

@implementation Operator

@synthesize name                =   _name;
@synthesize executeSelectorStr  =   _executeSelectorStr;
@synthesize formatSelectorStr   =   _formatSelectorStr;
@synthesize operands            =   _operands;
@synthesize precedence          =   _precedence;
@synthesize parentheses         =   _parentheses;      

#pragma mark - Initializations

- (id) initWithName:(NSString *)opName
{
    self = [super init];
    self.name = opName;
    
    // Binary Operators
    
    if ([opName isEqualToString:@"+"]) {
        self.executeSelectorStr = @"add:to:";
        self.formatSelectorStr = @"formatAdd:to:";
        self.operands = 2;         
        self.precedence = 1;
    } 
    else if ([opName isEqualToString:@"*"]) {
        self.executeSelectorStr = @"mult:by:";
        self.formatSelectorStr = @"formatMult:by:";
        self.operands = 2;         
        self.precedence = 2;
    } 
    else if ([opName isEqualToString:@"-"]) {
        self.executeSelectorStr = @"sub:by:";
        self.formatSelectorStr = @"formatSub:by:";
        self.operands = 2;         
        self.precedence = 1;
    } 
    else if ([opName isEqualToString:@"/"]) {
        self.executeSelectorStr = @"div:by:";
        self.formatSelectorStr = @"formatDiv:by:";
        self.operands = 2;         
        self.precedence = 2;
    } 
    
    // Unary Operations
    
    else if ([opName isEqualToString:@"√"]) {
        self.executeSelectorStr = @"sqrt:";
        self.formatSelectorStr = @"formatSqrt:";
        self.operands = 1;         
        self.precedence = 3;
        self.parentheses = YES;
    }
    else if ([opName isEqualToString:@"sin"]) {
        self.executeSelectorStr = @"sin:";
        self.formatSelectorStr = @"formatSin:";
        self.operands = 1;         
        self.precedence = 3;
        self.parentheses = YES;
    }
    else if ([opName isEqualToString:@"cos"]) {
        self.executeSelectorStr = @"cos:";
        self.formatSelectorStr = @"formatCos:";
        self.operands = 1;         
        self.precedence = 3;
        self.parentheses = YES;
    }
    else if ([opName isEqualToString:@"±"]) {
        self.executeSelectorStr = @"plusMinus:";
        self.formatSelectorStr = @"formatPlusMinus:";
        self.operands = 1;         
        self.precedence = 3;
        self.parentheses = YES;
    }
    
    // Nullary Operations
    
    else if ([opName isEqualToString:@"π"]) {
        self.executeSelectorStr = @"pi";
        self.formatSelectorStr = @"formatPI";
        self.operands = 0;         
        self.precedence = 3;
    }
    
    return self;
}

+ (NSSet *) setWithAllOperators
{
    static NSSet * _opSetCache = nil;
    if (!_opSetCache) {
        _opSetCache = [[NSSet alloc] initWithObjects:
                       @"+",
                       @"*",
                       @"-",
                       @"/",
                       @"√",
                       @"sin",
                       @"cos",  
                       @"±",
                       @"π",
                       nil];
    }
    return _opSetCache;
}

+ (NSMutableDictionary *) operatorsCache
{
    static NSMutableDictionary * _opCacheDict = nil;
    
    if (!_opCacheDict) {
        _opCacheDict = [[NSMutableDictionary alloc] init];
    }
    return _opCacheDict;
}

+ (Operator *) operatorFromName:(NSString *)opName
{
    Operator * _operator;
    
    id cachedOperator = [[self operatorsCache] objectForKey:opName];
    if (cachedOperator) {
        _operator = cachedOperator;
    } else {
        _operator = [[Operator alloc] initWithName:opName];         // expensive 
        [[self operatorsCache] setObject:_operator forKey:opName];   // cached
    }
    
    return _operator;
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma mark - Evaluations

- (NSNumber *) evalOperand:(NSNumber *)operand
{
    SEL executionSelector = NSSelectorFromString(self.executeSelectorStr);
    NSNumber *result = [self performSelector:executionSelector
                                  withObject:operand];
    return result;
}

- (NSNumber *) evalOperand:(NSNumber *)operand1 withOperand:(NSNumber *)operand2
{
    SEL executionSelector = NSSelectorFromString(self.executeSelectorStr);
    NSNumber *result = [self performSelector:executionSelector 
                                  withObject:operand1
                                  withObject:operand2];
    return result;
}

- (NSString *) formatOperand:(NSString *)opStr withinOperator:(Operator *)parent
{
    if (self.parentheses && [opStr characterAtIndex:0] != '(') 
        opStr = [NSString stringWithFormat:@"(%@)", opStr];
    
    SEL formatSelector = NSSelectorFromString(self.formatSelectorStr);
    NSString *resultStr = [self performSelector:formatSelector
                                     withObject:opStr];
    
    if (parent.precedence > self.precedence) 
        resultStr = [NSString stringWithFormat:@"(%@)", resultStr];
    
    return resultStr;
}

- (NSString *) formatOperand:(NSString *)opStr1 withOperand:(NSString *)opStr2 withinOperator:(Operator *)parent
{    
    SEL formatSelector = NSSelectorFromString(self.formatSelectorStr);
    NSString *resultStr = [self performSelector:formatSelector
                                     withObject:opStr1
                                     withObject:opStr2];
    
    if (parent.precedence > self.precedence) 
        resultStr = [NSString stringWithFormat:@"(%@)", resultStr];
    
    return resultStr;
}


#pragma SEL functions

- (NSNumber *) add:(NSNumber *)a to:(NSNumber *)b 
{
    return [NSNumber numberWithDouble:[a doubleValue] + [b doubleValue]];
}
- (NSString *) formatAdd:(NSString *)a to:(NSString *)b 
{
    return [NSString stringWithFormat:@"%@ + %@", a, b];
}

- (NSNumber*) mult:(NSNumber *)a by:(NSNumber *)b
{
    return [NSNumber numberWithDouble:[a doubleValue] * [b doubleValue]];
}
- (NSString *) formatMult:(NSString *)a by:(NSString *)b
{
    return [NSString stringWithFormat:@"%@ * %@", a, b];
}

- (NSNumber *) sub:(NSNumber *)a by:(NSNumber *)b 
{
    return [NSNumber numberWithDouble:[a doubleValue] - [b doubleValue]];
}
- (NSString *) formatSub:(NSString *)a by:(NSString *)b 
{
    return [NSString stringWithFormat:@"%@ - %@", a, b];
}

- (NSNumber *) div:(NSNumber *)a by:(NSNumber *)b
{
    double divisor = [b doubleValue];    
    return (divisor) ? [NSNumber numberWithDouble:[a doubleValue] / divisor] : [NSDecimalNumber notANumber];
}
- (NSString *) formatDiv:(NSString *)a by:(NSString *)b
{
    return [NSString stringWithFormat:@"%@ / %@", a, b];
}


- (NSNumber *) sqrt:(NSNumber *)a
{
    return [NSNumber numberWithDouble:sqrt([a doubleValue])];
}
- (NSString *) formatSqrt:(NSString *)a
{
    return [NSString stringWithFormat:@"√%@", a];
}

- (NSNumber *) sin:(NSNumber *)a
{
    return [NSNumber numberWithDouble:sin([a doubleValue])];
}
- (NSString *) formatSin:(NSString *)a
{
    return [NSString stringWithFormat:@"sin%@", a];
}

- (NSNumber *) cos:(NSNumber *)a
{
    return [NSNumber numberWithDouble:cos([a doubleValue])];
    
}
- (NSString *) formatCos:(NSString *)a
{
    return [NSString stringWithFormat:@"cos%@", a];
}

- (NSNumber *) plusMinus:(NSNumber *)a
{
    return [NSNumber numberWithDouble:-1.0 * [a doubleValue]];
}
- (NSString *) formatPlusMinus:(NSString *)a
{
    return [NSString stringWithFormat:@"±%@", a];
}

- (NSNumber *) pi
{
    return [NSNumber numberWithDouble:M_PI];
}
- (NSString *) formatPI
{
    return [NSString stringWithString:@"π"];
}

@end
