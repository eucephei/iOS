//
//  Segment.h
//  Caterpillar
//
//  Created by Apple User on 1/21/13.
//
//

#import "cocos2d.h"
#import "GameObject.h"

@interface Segment : GameObject

@property (nonatomic, assign) CGPoint previousPosition;
@property (nonatomic, assign) Segment *parent;

@end
