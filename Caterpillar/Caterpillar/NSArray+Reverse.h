//
//  NSArray+Reverse.h
//  Caterpillar
//
//  Created by Apple User on 1/22/13.
//
//

#import <Foundation/Foundation.h>

@interface NSArray(Reverse)
- (NSArray *)reversedArray;
@end

@interface NSMutableArray(Reverse)
- (void)reverse;
@end
