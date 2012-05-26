//
//  Operator.h
//  Calculator
//
//  Created by ace on 24/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Operator : NSObject

@property (nonatomic, strong) NSString *  name;
@property (nonatomic, assign) NSString *  executeSelectorStr;
@property (nonatomic, assign) NSString *  formatSelectorStr;
@property (nonatomic)         int         operands;
@property (nonatomic)         int         precedence;
@property (nonatomic)         BOOL        parentheses;

+ (NSSet *) setWithAllOperators;
+ (NSMutableDictionary *) operatorsCache;
+ (Operator *) operatorFromName:(NSString *)opName;

- (NSNumber *) evalOperand:(NSNumber *)operand;
- (NSNumber *) evalOperand:(NSNumber *)operand1 withOperand:(NSNumber *)operand2;
- (NSString *) formatOperand:(NSString *)opStr withinOperator:(Operator *)parent;
- (NSString *) formatOperand:(NSString *)opStr1 withOperand:(NSString *)opStr2 withinOperator:(Operator *)parent;

@end
