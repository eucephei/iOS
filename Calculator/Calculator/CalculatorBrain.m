//
//  CalculatorBrain.m
//  CalculatorBrain
//
//  Created by ace on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#import "Operator.h"

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
    NSLog(@"brain: operand is: %@", (NSString*)operand);   // NSNumber or NSString
    [self.programStack addObject:operand];             
}

- (id)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    NSNumber *result = [[self class] runProgram:self.program usingVariableValues:nil];
    NSLog(@"brain: operation result is: %@", result);
    
    return result;
}

#pragma mark - Class Methods

// returns a mutable copy of program array
+ (NSMutableArray *) copyProgram:(id)program 
{
    NSMutableArray *stack;
    
    if ([program isKindOfClass:[NSArray class]]) 
        stack = [program mutableCopy];
    
    return stack;
}

+ (BOOL) isOperator:(id)expression
{
    return [expression isKindOfClass:[NSString class]] && [[[Operator class] setWithAllOperators] containsObject:expression];
}

+ (BOOL) isVariable:(id)numOrVar
{
    return [numOrVar isKindOfClass:[NSString class]]; 
}

+ (NSString *) describeProgram:(NSMutableArray *)stack inOperatorContext:(Operator *)parentOperator
{
    NSString *description;
    
    id top = [stack lastObject];
    if (top) [stack removeLastObject];
    else description = @"0";
    
    if ([top isKindOfClass:[NSNumber class]]) 
        
        // OPERAND number
        description = [top stringValue];
    
    else if ([top isKindOfClass:[NSString class]]) { 
        
        // OPERAND variable
        if (![[self class] isOperator:top]) 
            description = top;
        
        // OPERATOR
        else {
            Operator *myOperator = [Operator operatorFromName:top];
            int numOperands = myOperator.operands;
            
            NSString * operand1, * operand2;
            switch (numOperands) {
                case 0: // Nullary 
                    description = [myOperator formatOperand:top
                                             withinOperator:parentOperator];
                    break;
                case 1: // Unary
                    operand1 = [[self class] describeProgram:stack inOperatorContext:myOperator];
                    description = [myOperator formatOperand:operand1
                                             withinOperator:parentOperator];
                    break;
                case 2: // Binary
                    operand1 = [[self class] describeProgram:stack
                                           inOperatorContext:myOperator];
                    operand2 = [[self class] describeProgram:stack 
                                           inOperatorContext:myOperator];
                    description = [myOperator formatOperand:operand2
                                                withOperand:operand1
                                             withinOperator:parentOperator];
                    break;
                default:
                    NSLog(@"brain: operator '%@' should not have %d operands!", top, numOperands);
            } 
        } 
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *description = @"";
    
    NSMutableArray *stack = [self copyProgram:program];
    while ([stack count]) {
        NSString * nextTerm = [[self class] describeProgram:stack inOperatorContext:nil];
        if ([description length]) 
            nextTerm = [nextTerm stringByAppendingString:@", "];
        
        description = [nextTerm stringByAppendingString:description];
    }
    
    return description;
}

+ (NSSet *)variablesUsedInProgram:(id)program 
{
    NSSet *variables;      
    
    NSArray *stack = [self copyProgram:program]; 
    if (stack) {
        for (id element in stack) {
            if (![self isOperator:element] && [self isVariable:element]) {
                variables = (!variables) 
                ? [NSSet setWithObject:element] 
                : [variables setByAddingObject:element]; 
            }
        }
        NSLog(@"brain: variables = %@", variables); 
    }
    
    return variables;
}

+ (NSNumber *) popAndEval:(NSMutableArray *)stack usingVariableValues:(NSDictionary *)varsDict;
{
    NSNumber *result = 0;
    
    id top = [stack lastObject];
    if (top) [stack removeLastObject];
    else return result;
    
    // OPERAND
    if (![[self class] isOperator:top]) {
        if (![[self class] isVariable:top]) 
            result = top;
        else
            result = [varsDict objectForKey:top];       // result = 0 if object not found 
    }
    
    // OPERATOR    
    else {
        Operator *myOperator = [Operator operatorFromName:top];
        int numOperands = myOperator.operands;        
        
        NSNumber *operand1, * operand2;
        switch (numOperands) {
            case 0: // Nullary 
                result = [myOperator evalOperand:top]; 
                break;
            case 1: // Unary 
                operand1 = [[self class] popAndEval:stack usingVariableValues:varsDict]; 
                result = [myOperator evalOperand:operand1]; 
                break;
            case 2: // Binary 
                operand1 = [[self class] popAndEval:stack usingVariableValues:varsDict];
                operand2 = [[self class] popAndEval:stack usingVariableValues:varsDict];
                result = [myOperator evalOperand:operand2 withOperand:operand1];
                break;
            default:
                NSLog(@"brain: eval operator '%@' should not have %d operands!", top, numOperands);
        }
    }
    
    return result;
}

+ (NSNumber *) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
{
    NSMutableArray *stack = [self copyProgram:program];
    
    return [self popAndEval:stack usingVariableValues:variableValues];
}


@end
