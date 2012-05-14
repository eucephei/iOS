//
//  CalculatorBrain.h
//  CalculatorBrain
//
//  Created by ace on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)clear;
- (void)undo;
- (void)pushOperand:(id)operand;
- (id)performOperation:(NSString *)op;

@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSNumber*)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSNumber*)runProgram:(id)program;


@end
