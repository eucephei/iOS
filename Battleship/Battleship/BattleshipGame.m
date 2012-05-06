//
//  BattleshipGame.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattleshipGame.h"
#import "BattleshipGrid.h"
#import "BattleshipTurn.h"

#define kMaxPacketSize 1024

NSString* const BattleshipGameNewOpponentTurnNotification = @"BattleshipGameNewOpponentTurnNotification";
NSString* const BattleshipGameKeyNewOpponentTurn = @"BattleshipGameKeyNewOpponentTurn";

@interface BattleshipGame () <GKPeerPickerControllerDelegate, GKSessionDelegate>
 @property (nonatomic,retain) GKPeerPickerController* peerPicker;
 @property (nonatomic,retain) GKSession* gameSession;
 @property (nonatomic,copy) NSString* gamePeerID;
 - (void) invalidateSession:(GKSession *)session;
@end

@implementation BattleshipGame

@synthesize grid = _grid;
@synthesize playerTurns = _playerTurns;
@synthesize opponentTurns = _opponentTurns;
@synthesize playerHits = _playerHits;
@synthesize opponentHits = _opponentHits;

@synthesize peerPicker = _peerPicker;
@synthesize gameSession = _gameSession;
@synthesize gamePeerID = _gamePeerID;

- (void) dealloc 
{
	[_peerPicker release], _peerPicker = nil;
	[_gameSession release], _gameSession = nil;
	[_gamePeerID release], _gamePeerID = nil;
	
	[_grid release], _grid = nil;
	[_playerTurns release], _playerTurns = nil;
	[_opponentTurns release], _opponentTurns = nil;
    _playerHits = 0; _opponentHits = 0;
    
	[super dealloc];
}

- (id) initWithGrid:(BattleshipGrid*)grid 
{
	self = [super init];
	if ( self != nil ) {
		_grid = [grid retain];
		_playerTurns = [[NSMutableArray alloc] init];
		_opponentTurns = [[NSMutableArray alloc] init];
        _playerHits = 0; _opponentHits = 0;
	}
	return self;
}

- (BattleshipTurnResultType) fireOnIndexPath:(NSIndexPath*)indexPath 
{    
	for ( BattleshipTurn* turn in self.playerTurns ) {
		if ( [turn.indexPath isEqual:indexPath] ) {
			return BattleshipTurnResultAlreadyTried;
		}
	}
	
	BattleshipTurn* turn = [[BattleshipTurn alloc] initWithIndexPath:indexPath];
	BattleshipTurnResultType result = [self.grid resultForIndexPath:indexPath];
	turn.result = result;
	[self.playerTurns addObject:turn];
    if (result == BattleshipTurnResultHit) { 
        _playerHits++;
    }
	[self addOpponentTurn:turn];
    if (result == BattleshipTurnResultHit) { 
        _opponentHits++;    
    }
    [turn release];
	
	return result;
}

- (void) addOpponentTurn:(BattleshipTurn*)turn 
{
	[self.opponentTurns addObject:turn];
	NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:turn, BattleshipGameKeyNewOpponentTurn, nil];
	[[NSNotificationCenter defaultCenter] 
            postNotificationName:BattleshipGameNewOpponentTurnNotification 
                          object:self 
                        userInfo:info];
}

#pragma mark - GameKit

-(void) startPeerPicker 
{
	GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
	picker.delegate = self;
	self.peerPicker = picker;
	[picker show]; // show the Peer Picker
	[picker release];
}

- (void) invalidateSession:(GKSession *)session 
{
	if( session != nil ) {
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	NSLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] );
}

#pragma mark - GKPeerPickerControllerDelegate

- (void) peerPickerControllerDidCancel:(GKPeerPickerController *)picker 
{ 
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
	
	self.peerPicker.delegate = nil;
	self.peerPicker = nil;
	
	// invalidate and release game session if one is around.
	if( self.gameSession != nil )	{
		[self invalidateSession:self.gameSession];
		self.gameSession = nil;
	}
} 

- (void) peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session 
{ 
	// Remember the current peer.
	self.gamePeerID = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	self.gameSession = session; // retain
	self.gameSession.delegate = self; 
	[self.gameSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	self.peerPicker.delegate = nil;
	self.peerPicker = nil;
	
	NSError* error = nil;
	NSData* gridData = [NSKeyedArchiver archivedDataWithRootObject:self.grid];
	[self.gameSession sendData:gridData toPeers:[NSArray arrayWithObject:self.gamePeerID] withDataMode:GKSendDataReliable error:&error];
} 

#pragma mark - GKSessionDelegate

/*
// Can ignore when using GKPeerPickerController
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
}
 
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state 
{	
} 
 */

- (void)session:(GKSession *)session didFailWithError:(NSError *)error 
{
	NSLog(@"ERR: %s %@", __PRETTY_FUNCTION__, [error localizedDescription]);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID 
{	
}




@end
