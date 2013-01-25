//
//  PauseScene.m
//  Caterpillar
//
//  Created by Apple User on 1/25/13.
//
//

#import "PauseLayer.h"
#import "GameLayer.h"

@implementation PauseLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [[CCScene node] autorelease];
    
	// 'layer' is an autorelease object.
	PauseLayer *layer = [[PauseLayer node] autorelease];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
        
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Paused"
                                               fontName:@"Marker Felt" fontSize:60];
        label.position = ccp(160, 240);
        [self addChild:label];
        
        [CCMenuItemFont setFontName:@"Marker Felt"];
        [CCMenuItemFont setFontSize:35];
        
        CCMenuItem *Resume = [CCMenuItemFont itemFromString:@"Resume"
                                                     target:self
                                                   selector:@selector(resume:)];
        
        CCMenuItem *Quit = [CCMenuItemFont itemFromString:@"Quit!"
                                                   target:self
                                                 selector:@selector(GoToMainMenu:)];
        
        CCMenu *menu = [CCMenu menuWithItems: Resume, Quit, nil];
        menu.position = ccp(131.67f, 240);
        
        [menu alignItemsVerticallyWithPadding:92.5f];
        
        [self addChild:menu];
    }
    return self;
}

-(void) resume: (id) sender
{
    
	[[CCDirector sharedDirector] popScene];
}

-(void) GoToMainMenu: (id) sender
{
	[[CCDirector sharedDirector] sendCleanupToScene];
	[[CCDirector sharedDirector] popScene];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade
                                               transitionWithDuration:1
                                               scene:[GameLayer node]]];
}

@end
