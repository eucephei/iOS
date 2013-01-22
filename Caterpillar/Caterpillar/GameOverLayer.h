//
//  GameOverLayer.h
//  Caterpillar
//
//  Created by Apple User on 1/22/13.
//
//

#import "cocos2d.h"
#import "GameConfig.h"

@interface GameOverLayer : CCLayer

@property (nonatomic, assign) NSInteger score;
@property(nonatomic, retain) CCLabelTTF *scoreLabel;
@property(nonatomic, retain) CCLabelTTF *highScoreLabel;

+(CCScene *) sceneWithScore:(NSInteger) score;

@end