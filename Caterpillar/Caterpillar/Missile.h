//
//  Missile.h
//  Caterpillar
//
//  Created by Apple User on 1/22/13.
//
//

#import "cocos2d.h"
#import "GameObject.h"

@interface Missile : GameObject

@property (nonatomic, assign) BOOL dirty;

- (void)update:(ccTime)dt;

@end
