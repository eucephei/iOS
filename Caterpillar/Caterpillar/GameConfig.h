//
//  GameConfig.h
//  Caterpillar
//
//  Created by Apple User on 1/17/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone               0
#define kGameAutorotationCCDirector         1
#define kGameAutorotationUIViewController   2

// Sprouts
#define kSproutLives            3

#define kStartingSproutsCount   50
#define kGridCellSize           16
#define kColumns                18
#define kRows                   20

#define kGameAreaStartX         24
#define kGameAreaStartY         64
#define kGameAreaHeight         353
#define kGameAreaWidth          288

#define kPlayerStartingLives    3

#define kNotificationPlayerLives @"PlayerLivesNotification"
#define kNotificationPlayerScore @"PlayerScoreNotification"

#define kCaterpillarLength      11

#define kMissileSpeed           1.0
#define kMissileMaxSpeed        10.0
#define kMissilesTotal          20
#define kMissileFrequency       .6 //seconds
#define kMinMissileFrequency    .2

#define kPlayerInvincibleTime   15

#define kSproutHitPoints        25
#define kCaterpillarHitPoints   200
#define kNextLevelPoints        1000

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationUIViewController


#endif // __GAME_CONFIG_H