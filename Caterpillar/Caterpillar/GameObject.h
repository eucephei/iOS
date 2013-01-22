//
//  GameObject.h
//  Caterpillar
//
//  Created by Apple User on 1/20/13.
//
//

#import "cocos2d.h"
#import "GameLayer.h"

@interface GameObject : NSObject

@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, assign) GameLayer *gameLayer;
@property (nonatomic) CGPoint position;

- (id)initWithGameLayer:(GameLayer *)layer;
- (CGRect)getBounds;

@end
