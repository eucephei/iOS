//
//  TitleLayer.m
//  Caterpillar
//
//  Created by Apple User on 1/17/13.
//
//

#import "TitleLayer.h"
#import "GameLayer.h"
#import "CCTransition.h"

@implementation TitleLayer

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    
    TitleLayer *layer = [TitleLayer node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    if( (self=[super init])) {
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        
        // loads the background image
        CCSprite * background = [CCSprite spriteWithFile:@"title.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background];
        
        // enables any layer in Cocos2D to accept touches
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // faded transition from the TitleScene to the GameScene
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.5 scene:[GameLayer scene] withColor:ccWHITE]];
    return YES;
}


@end
