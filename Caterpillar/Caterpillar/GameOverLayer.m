//
//  GameOverLayer.m
//  Caterpillar
//
//  Created by Apple User on 1/22/13.
//
//

#import "GameOverLayer.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"

@implementation GameOverLayer

@synthesize score = _score;
@synthesize scoreLabel = _scoreLabel;
@synthesize highScoreLabel = _highScoreLabel;

+(CCScene *) sceneWithScore:(NSInteger) score
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOverLayer *layer = [GameOverLayer node];
	layer.score = score;
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)dealloc
{
    [_scoreLabel release];
    [_highScoreLabel release];
    [super dealloc];
}

-(id) init
{
	if( (self=[super init])) {
        
        // Render background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite * background = [CCSprite spriteWithFile:@"game-over.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background];
        
        _scoreLabel = [[CCLabelTTF labelWithString:@"0"
                                        dimensions:CGSizeMake(320, 30)
                                         alignment:NSTextAlignmentCenter
                                          fontName:@"Helvetica"
                                          fontSize:30] retain];
        _scoreLabel.anchorPoint = ccp(0,0);
        
        _scoreLabel.position = ccp(0,155);
        [self addChild:_scoreLabel];
        
        _highScoreLabel = [[CCLabelTTF labelWithString:[NSString stringWithFormat:@"High: %d",0]
                                            dimensions:CGSizeMake(320, 35)
                                             alignment:NSTextAlignmentCenter
                                              fontName:@"Helvetica"
                                              fontSize:30] retain];
        _highScoreLabel.anchorPoint = ccp(0,0);
        _highScoreLabel.color = (ccColor3B){255,0,0};
        
        _highScoreLabel.position = ccp(0,195);
        [self addChild:_highScoreLabel];
        
        // Enable touches
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"game-over.caf"];
        
    }
    return self;
}

- (void)setScore:(NSInteger)score
{
    _score = score;
    self.scoreLabel.string = [NSString stringWithFormat:@"Score: %d",_score];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger highScore = [defaults integerForKey:@"CentipedeHighScore"];
    
    if(score > highScore) {
        highScore = score;
        [defaults setInteger:score forKey:@"CentipedeHighScore"];
        [defaults synchronize];
    }
    
    self.highScoreLabel.string = [NSString stringWithFormat:@"High: %d",highScore];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.5 scene:[GameLayer scene] withColor:ccWHITE]];
    return YES;
}


@end
