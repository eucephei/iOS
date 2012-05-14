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

- (void)clear
{
    [self.programStack removeAllObjects];
}

-(void) undo 
{ 
    [self.programStack removeLastObject];
}

- (void)pushOperand:(id)operand            
{
    NSLog(@"operand is: %@", (NSString*)operand);  
    // if ([operand isKindOfClass:[NSNumber class]]) 
    // else if ([operand isKindOfClass:[NSString class]])
    [self.programStack addObject:operand];
}

- (id)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    NSNumber* result = [[self class] runProgram:self.program usingVariableValues:nil];
    NSLog(@"operation result is: %@", result);
    return result;
}

#pragma mark - Class Methods

// multiply,divide operations require no extra parenthesis
+ (NSSet *)repeatOperations
{
    return [NSSet setWithObjects:@"*", @"/", nil];
}

// add/subtract operations require extra parenthesis to denote precedence
+ (NSSet *)binaryOperations
{
    NSMutableSet *repeatSet = [[self repeatOperations] mutableCopy];
    [repeatSet unionSet:[NSSet setWithObjects:@"+",@"-", nil]];
    return repeatSet;
}

// unary operations
+ (NSSet *)unaryOperations
{
    return [NSSet setWithObjects:@"sin",@"cos",@"√",@"±",nil];
}

// nullary operations
+ (NSSet *)nullaryOperations 
{
    return [NSSet setWithObjects:@"π",nil];
}

// is an operation
+ (BOOL) isOperation:(NSString *)operation
{
    NSMutableSet *operators =[NSMutableSet setWithSet:[self binaryOperations]];
    [operators unionSet:[self unaryOperations]];
    [operators unionSet:[self nullaryOperations]];    
    return [operators containsObject:operation];
}

// is a variable
+ (BOOL) isVariable:(NSString *)variable
{
    NSSet *variables = [NSSet setWithObjects:@"x",@"y",@"z", nil];
    return [variables containsObject:variable];
}

// no need for extra parentheses when the expression has them already 
+ (BOOL) hasParethenses:(NSString *)expression
{
    return ([@"(" isEqualToString:[expression substringToIndex:1]] && [@")" isEqualToString:[expression substringFromIndex:([expression length] - 1)]]);
}

// recursive helper function for descriptionOfProgram
+ (NSString *) descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description;
    id top = [stack lastObject]; 
    if (top) [stack removeLastObject];
    else description = @"0";
    
    if ([top isKindOfClass:[NSNumber class]]){              // it is a number 
        description = [top stringValue];
    } else if ([top isKindOfClass:[NSString class]]){       // it is an operation   
        NSString *operation = top;
        
        if ([[self binaryOperations] containsObject:operation]) {          // binary operation                                                                  
            NSString *topExpression = [self descriptionOfTopOfStack:stack];
            NSString *format = @"(%@ %@ %@)";               
            if ([[self repeatOperations] containsObject:operation])        // *,/ operation
                format = @"%@ %@ %@";
            description = [NSString stringWithFormat:format,
                                    [self descriptionOfTopOfStack:stack],
                                    operation,
                                    topExpression];
        } else if ([[self unaryOperations] containsObject:operation]) {     // unary operation                                                 
            NSString *topExpression = [self descriptionOfTopOfStack:stack];
            NSString *format = ([self hasParethenses:topExpression]) ? @"%@%@" : @"%@(%@)";
            description = [NSString stringWithFormat:format,
                                    operation, 
                                    topExpression];
        } else {
            description = operation;
        }
    }
    
    return description;
}

// returns a mutable copy of program array
+ (NSMutableArray *) copyProgram:(id)program 
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) 
        stack = [program mutableCopy];
    
    return stack;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *description = [self descriptionOfTopOfStack:[self copyProgram:program]];
    
    // remove the extra parentheses if the expression has them already
    if ([self hasParethenses:description]) {
        NSRange range = NSMakeRange(1, [description length] -2);
        description = [description substringWithRange:range];
    }

    return description;
}

+ (NSSet *)variablesUsedInProgram:(id)program 
{
    NSSet *variables;      
    NSArray *stack = [self copyProgram:program]; 
    if (stack) {
        for (id element in stack) {
            if ([element isKindOfClass:[NSString class]]){
                NSString *str = element;
                if (![self isOperation:str] && [self isVariable:str]) {
                    variables = (!variables) 
                        ? [NSSet setWithObject:str] 
                    : [variables setByAddingObject:str];
                }
                NSLog(@"variables = %@", variables);
            }
        }
    }

    return variables;
}

// recursive pop operands off stack
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
            result = (divisor) ? [self popOperand:stack] / divisor : NAN;
        } else if ([operation isEqualToString:@"√"]) {
            result = sqrt([self popOperand:stack]);
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperand:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperand:stack]);
        } else if ([operation isEqualToString:@"±"]) {
            result = -1.0 * [self popOperand:stack];
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }   
    }
    
    return result;
}

+ (NSNumber*)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
{
    NSMutableArray *stack = [self copyProgram:program];
    
    NSSet *variables = [self variablesUsedInProgram:program];
    if (variables) {
        for (int i = 0; i < [stack count]; i++) {
            id element = [stack objectAtIndex:i];
            if ([variables containsObject:element] && [variableValues objectForKey:element])
                [stack replaceObjectAtIndex:i withObject:[variableValues objectForKey:element]];
        }
    }
    
    return [NSNumber numberWithDouble:[self popOperand:stack]];
}

+ (NSNumber*)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

@end
