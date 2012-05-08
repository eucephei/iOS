//
//  CalculatorBrain.m
//  CalculatorBrain
//
//  Created by ace on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

#pragma mark - Accessors

- (NSMutableArray *)programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

#pragma mark - Instance Methods

- (void)reset
{
    [self.programStack removeAllObjects];
    self.programStack = nil;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

#pragma mark - Class Methods


+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this!";
}


+ (double)popOperand:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) 
        result = [topOfStack doubleValue];
    else if ([topOfStack isKindOfClass:[NSString class]]) 
    {
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperand:stack] + [self popOperand:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperand:stack] * [self popOperand:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperand:stack];
            result = [self popOperand:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperand:stack];
            if (divisor) result = [self popOperand:stack] / divisor;
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperand:stack]);
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperand:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperand:stack]);
        } else if ([operation isEqualToString:@"+/-"]) {
            result = -1.0 * [self popOperand:stack];
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperand:stack];
}


@end
