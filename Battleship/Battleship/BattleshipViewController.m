//
//  BattleshipViewController.m
//  Battleship
//
//  Created by ace on 16/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BattleshipViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#import "BattleshipGridView.h"
#import "BattleshipViewHit.h"
#import "BattleshipViewMiss.h"

#import "Battleship.h"
#import "BattleshipGame.h"
#import "BattleshipGrid.h"
#import "BattleshipTurn.h"

@interface BattleshipViewController ()
 @property (nonatomic,retain) BattleshipGame* game;
 @property (nonatomic,retain) NSMutableSet* shipDragControllers;
 @property (nonatomic,retain) NSMutableSet* shipRotateControllers;
 @property (nonatomic,retain) NSArray* originalShipLocations;
 @property (nonatomic,assign,readonly) SystemSoundID explosionSound;
 @property (nonatomic,assign,readonly) SystemSoundID splashSound; 
 - (NSIndexPath*) indexPathForPoint:(CGPoint)point inGridView:(BattleshipGridView*) view;
 - (void) gridView:(BattleshipGridView*)gridView addTurnResult:(BattleshipTurnResultType)result forIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated;
 - (void) endGame;
@end

@implementation BattleshipViewController

@synthesize ships = _ships;
@synthesize gridView = _gridView;
@synthesize opponentGridView;
@synthesize gridLabel;
@synthesize beginGameButton;
@synthesize playerPageControl;
@synthesize pageControl;
@synthesize scrollView = _scrollView;
@synthesize playerPageControlLabel;
@synthesize opponentPageControlLabel;
@synthesize gameKitButton;
@synthesize game = _game;
@synthesize shipDragControllers = _shipDragControllers;
@synthesize shipRotateControllers = _shipRotateControllers;
@synthesize originalShipLocations = _originalShipLocations;

@synthesize explosionSound = _explosionSound;
@synthesize splashSound = _splashSound;

- (void) releaseOutlets 
{
	[self setGridView:nil];
	[self setOpponentGridView:nil];
	[self setGridLabel:nil];
	[self setShips:nil];
	[self setBeginGameButton:nil];
	[self setPlayerPageControl:nil];
	[self setPageControl:nil];
	[self setPlayerPageControlLabel:nil];
	[self setOpponentPageControlLabel:nil];
	
	[self setScrollView:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:BattleshipGameNewOpponentTurnNotification object:nil];
	
	[self releaseOutlets];
	
	[_game release], _game = nil;
	[_shipDragControllers release], _shipDragControllers = nil;
	[_shipRotateControllers release], _shipRotateControllers = nil;
	[_originalShipLocations release], _originalShipLocations = nil;
	
	[gameKitButton release];
	if ( _explosionSound != 0 ) {
		AudioServicesDisposeSystemSoundID( _explosionSound );
	}
	
	if ( _splashSound != 0 ) {
		AudioServicesDisposeSystemSoundID( _splashSound );
	}
	
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_shipDragControllers = [[NSMutableSet alloc] init];
		_shipRotateControllers = [[NSMutableSet alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(opponentTurnWasAdded:)
                                                     name:BattleshipGameNewOpponentTurnNotification
                                                   object:nil];        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) hidePlayerPageControlAnimated:(BOOL)animated 
{
	CGRect frame = self.playerPageControl.frame;
	frame.origin.y = CGRectGetMaxY([self.view convertRect:self.gridView.frame toView:self.view]) - CGRectGetHeight(self.playerPageControl.frame);
    
	[UIView animateWithDuration:(animated ? 0.2 : 0.0)
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){self.playerPageControl.frame = frame;}
                     completion:nil];
}

- (void) showPlayerPageControlAnimated:(BOOL)animated 
{
	CGRect frame = self.playerPageControl.frame;
	frame.origin.y = CGRectGetMaxY(self.scrollView.frame);
	[UIView animateWithDuration:(animated ? 0.2 : 0.0)
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){self.playerPageControl.frame = frame;} 
                     completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
	self.gridLabel.text = @"";
	
	self.beginGameButton.enabled = NO;
	self.beginGameButton.alpha = 0.0;
	self.beginGameButton.hidden = NO;
	
	self.gameKitButton.enabled = self.game != nil;
	
	CGSize scrollContentSize = self.scrollView.frame.size;
	scrollContentSize.width *= 2;
	self.scrollView.contentSize = scrollContentSize;
	self.scrollView.scrollEnabled = NO;
	
	[self hidePlayerPageControlAnimated:NO];
	
	UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gridTapped:)];
	[self.gridView addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
	
	tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(opponentGridTapped:)];
	[self.opponentGridView addGestureRecognizer:tapRecognizer];
	[tapRecognizer release];
	
	UIPanGestureRecognizer* dragRecognizer = nil;
	UIRotationGestureRecognizer* rotationRecognizer = nil;
	NSMutableArray* originalLocations = [NSMutableArray array];
	for ( UIView* ship in self.ships ) {
		[originalLocations addObject:[NSValue valueWithCGRect:ship.frame]];
		
		tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gridTapped:)];
		[ship addGestureRecognizer:tapRecognizer];
		[tapRecognizer release];
		
		dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragShipPiece:)];
		[ship addGestureRecognizer:dragRecognizer];
		[self.shipDragControllers addObject:dragRecognizer];
		[dragRecognizer release];
		
		rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateShipPiece:)];
		[ship addGestureRecognizer:rotationRecognizer];
		[self.shipRotateControllers addObject:rotationRecognizer];
		[rotationRecognizer release];
	}
	
	self.originalShipLocations = [[originalLocations copy] autorelease];
    
}

- (void)viewDidUnload
{
	[self releaseOutlets];
	
	[self setPlayerPageControlLabel:nil];
	[self setOpponentPageControlLabel:nil];
	[self setOpponentGridView:nil];
	[self setGameKitButton:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Notifications

- (void) opponentTurnWasAdded:(NSNotification*)notification 
{
	BattleshipTurn* turn = [[notification userInfo] objectForKey:BattleshipGameKeyNewOpponentTurn];
	// These notifications aren't guaranteed to come in on main queue, so ensure we update the display on main
	// This uses GCD instead of performSelector:withObject:afterDelay: because the method takes three parameters
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self gridView:self.gridView addTurnResult:turn.result forIndexPath:turn.indexPath animated:NO];
	});
}

#pragma mark -

- (IBAction)beginGame:(id)sender 
{
	if ( self.game != nil ) {
		// end game
		self.game = nil;
        
        [self.gridView removeSubViewClass:[BattleshipViewMiss class]];
        [self.gridView removeSubViewClass:[BattleshipViewHit class]];
        [self.opponentGridView removeSubViewClass:[BattleshipViewMiss class]];
        [self.opponentGridView removeSubViewClass:[BattleshipViewHit class]];
        [self.opponentGridView setUserInteractionEnabled:YES];
        
		self.beginGameButton.alpha = 0.0;
		[self.beginGameButton setTitle:@"Begin Game" forState:UIControlStateNormal];
		self.scrollView.scrollEnabled = NO;
		[self.scrollView setContentOffset:CGPointZero animated:YES];
		[self hidePlayerPageControlAnimated:YES];
		
		for ( UIGestureRecognizer* recognizer in [self.shipDragControllers allObjects] ) {
			recognizer.enabled = YES;
		}
		for ( UIGestureRecognizer* recognizer in [self.shipRotateControllers allObjects] ) {
			recognizer.enabled = YES;
		}
		
		[UIView animateWithDuration:0.6
                         animations:^(void) {
                             NSInteger index = 0;
                             for ( UIView* ship in self.ships ) {
                                 [self.view addSubview:ship];
                                 CGRect frame = [[self.originalShipLocations objectAtIndex:index++] CGRectValue];
                                 ship.transform = CGAffineTransformIdentity;
                                 ship.frame = frame;
                             }
                         } 
                         completion:^(BOOL finished) {}
        ];
	}
	else {
		// begin game
		
		// Move the ships from subviews of our main view to subviews of grid view
		// so they will scroll along with that grid view
		for ( UIView* ship in self.ships ) {
			CGRect frame = ship.frame;
			frame = [self.view convertRect:frame toView:self.gridView];
			[self.gridView addSubview:ship];
			ship.frame = frame;
		}
		
		[self.beginGameButton setTitle:@"End Game" forState:UIControlStateNormal];
		self.scrollView.scrollEnabled = YES;
		[self showPlayerPageControlAnimated:YES];
		
		for ( UIGestureRecognizer* recognizer in [self.shipDragControllers allObjects] ) {
			recognizer.enabled = NO;
		}
		for ( UIGestureRecognizer* recognizer in [self.shipRotateControllers allObjects] ) {
			recognizer.enabled = NO;
		}
		
		// build grid model
		BattleshipGrid* grid = [[BattleshipGrid alloc] initWithRows:6 columns:6];
		for ( UIView* ship in self.ships ) {
			CGRect bounds = ship.bounds;
			NSMutableArray* gridLocs = [NSMutableArray array]; // array of indexPaths
			// Create a target point within the ship's bounds
			// Using CGPointZero results in weird shifts since it's right on the grid line
			// so offset it slightly
			CGPoint point = { .x = 1, .y = 1 };
			// Walk the ship horizontally (since they all start that way, their local coordinates always think that way)
			while ( CGRectContainsPoint(bounds, point) ) {
				// Translate that internal point on ship to point on grid
				CGPoint translatedPoint = [self.gridView convertPoint:point fromView:ship];
				// Find indexPath where the translated point lies in the containing grid
				NSIndexPath* indexPath = [self indexPathForPoint:translatedPoint inGridView:self.gridView];
				[gridLocs addObject:indexPath];
				// move horizontally further along the ship
				point.x += kGridSize;
			}
			//		NSLog(@"{%@}", [gridLocs componentsJoinedByString:@","]);
			Battleship* shipModel = [[Battleship alloc] initWithIndexPaths:gridLocs];
			[grid addShip:shipModel];
			[shipModel release];
		}
		
		self.game = [[[BattleshipGame alloc] initWithGrid:grid] autorelease];
        [grid release];
	}
	
	self.gameKitButton.enabled = self.game != nil;
}

- (void) checkGameBeginnable 
{
	BOOL allShipsInGrid = YES;
	BOOL shipsIntersect = NO;
	CGRect gridRectInView = [self.scrollView convertRect:self.gridView.frame toView:self.view];
	NSInteger index = 0;
	for ( UIView* ship in self.ships ) {
		if ( ! CGRectContainsRect(gridRectInView, ship.frame) ) {
			// this ship is not within grid
			allShipsInGrid = NO;
		}
		
		for ( UIView* otherShip in [self.ships subarrayWithRange:NSMakeRange(index + 1, [self.ships count] - index - 1)] ) {
			if ( CGRectIntersectsRect(ship.frame, otherShip.frame) ) {
				shipsIntersect = YES;
			}
		}
		
		index++;
	}
	
	[UIView animateWithDuration:(allShipsInGrid ? 0.3 : 0.1)
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^(void) {
                         [self.beginGameButton setHidden:!allShipsInGrid];
                         [self.beginGameButton setEnabled:(allShipsInGrid && !shipsIntersect)];
                         [self.beginGameButton setAlpha:(allShipsInGrid && !shipsIntersect ? 1.0 : 0.5)];}
                     completion:nil];
}

- (void) endGame
{
    [self.opponentGridView setUserInteractionEnabled:NO];
    UIAlertView* myAlertView = (self.game.opponentHits == MAX_HITS) 
        ? [[[UIAlertView alloc] initWithTitle:@"winner" message:@"You won" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] autorelease]
        : [[[UIAlertView alloc] initWithTitle:@"loser" message:@"You lost" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] autorelease];
    [myAlertView show];
}

- (void) gridView:(BattleshipGridView*)gridView addTurnResult:(BattleshipTurnResultType)result forIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated 
{
	CGRect frame = {
		.origin.x = kGridSize * [indexPath indexAtPosition:1],
		.origin.y = kGridSize * [indexPath indexAtPosition:0],
		.size.width = kGridSize,
		.size.height = kGridSize,
	};
	
	NSTimeInterval duration = animated ? 0.25 : 0.0;
	switch ( result ) {
		case BattleshipTurnResultHit: {
			UIView* view = [[BattleshipViewHit alloc] initWithFrame:frame];
			view.alpha = 0.0;
			view.transform = CGAffineTransformMakeScale(10.0, 10.0);
			[gridView addSubview:view];
			[UIView animateWithDuration:duration
                             animations:^(void) {
                                 view.alpha = 1.0;
                                 view.transform = CGAffineTransformIdentity;} 
                             completion:^(BOOL finished) {}];
			[view release];
			break;
		}
			
		case BattleshipTurnResultMiss: {
			UIView* view = [[BattleshipViewMiss alloc] initWithFrame:frame];
			view.alpha = 0.0;
			view.transform = CGAffineTransformMakeScale(10.0, 10.0);
			[gridView addSubview:view];
			[UIView animateWithDuration:duration
                             animations:^(void) {
                                 view.alpha = 1.0;
                                 view.transform = CGAffineTransformIdentity;} 
                             completion:^(BOOL finished) {}];
			[view release];
			break;
		}
		default:
			break;
	}
}

- (IBAction) choosePeer:(id)sender 
{
	[self.game startPeerPicker];
}

#pragma mark - UIGestureRecognizer selectors

- (NSIndexPath*) indexPathForPoint:(CGPoint)point inGridView:(BattleshipGridView*)view 
{
	if ( ! CGRectContainsPoint(view.bounds, point) ) {
		return nil;
	}
	
	NSInteger row = floor( point.y / kGridSize );
	NSIndexPath* indexPath = [NSIndexPath indexPathWithIndex:row];
	
	NSInteger col = floor( point.x / kGridSize );
	indexPath = [indexPath indexPathByAddingIndex:col];
	
	return indexPath;
}

- (void) gridTapped:(UIGestureRecognizer*)recognizer 
{
	CGPoint point = [recognizer locationInView:self.gridView];
	NSIndexPath* indexPath = [self indexPathForPoint:point inGridView:self.gridView];
	if ( indexPath == nil ) {
		return;
	}
	
	self.gridLabel.text = [BattleshipGrid labelForIndexPath:indexPath];
}


- (void) opponentGridTapped:(UIGestureRecognizer*)recognizer 
{
	CGPoint point = [recognizer locationInView:self.opponentGridView];
	NSIndexPath* indexPath = [self indexPathForPoint:point inGridView:self.opponentGridView];
	if ( indexPath == nil ) {
		return;
	}
	
	BattleshipTurnResultType result = [self.game fireOnIndexPath:indexPath];
	[self gridView:self.opponentGridView addTurnResult:result forIndexPath:indexPath animated:YES];
	
	// This should be more thorough--sounds when the remote opponent shoots at player
	// and actively in app, for example. For now, we'll just do it when tapping
	switch (result) {
		case BattleshipTurnResultHit:
			AudioServicesPlaySystemSound( self.explosionSound );
            //			AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
			break;
			
		case BattleshipTurnResultMiss:
			AudioServicesPlaySystemSound( self.splashSound );
			break;
			
		default:
			break;
	}
    
    // End game if all ships of player or opponent are sunk
    if (self.game.opponentHits == MAX_HITS || self.game.playerHits == MAX_HITS) {
        [self endGame];  
    }    
	
	self.gridLabel.text = [BattleshipGrid labelForIndexPath:indexPath];
}

- (void) dragShipPiece:(UIPanGestureRecognizer*)recognizer 
{
	if ( recognizer.state == UIGestureRecognizerStateBegan ) {
		[self.view bringSubviewToFront:recognizer.view];
	}
	else if ( recognizer.state == UIGestureRecognizerStateChanged ) {
		CGPoint translation = [recognizer translationInView:self.view];
		CGPoint center = recognizer.view.center;
		center.x += translation.x;
		center.y += translation.y;
		recognizer.view.center = center;
		[recognizer setTranslation:CGPointZero inView:self.view];
        [self checkGameBeginnable];
	}
	if ( recognizer.state == UIGestureRecognizerStateEnded ) {
		// do all our location calculations in self.view reference coordinates
		// since that's the space we're going to move the ships around in until game begins
		CGRect gridFrame = [self.scrollView convertRect:self.gridView.frame toView:self.view];
		CGRect shipFrame = [self.view convertRect:recognizer.view.frame toView:self.view];
		// adjust location to multiple of grid lines
		shipFrame.origin.x = gridFrame.origin.x + (kGridSize * round((shipFrame.origin.x - gridFrame.origin.x) / kGridSize));
		shipFrame.origin.y = gridFrame.origin.y + (kGridSize * round((shipFrame.origin.y - gridFrame.origin.y) / kGridSize));
		
		// only auto-move the ship if it would be completely within the grid
		// this isn't perfect, but keeps us from auto-moving when outside the grid
		if ( CGRectContainsRect(gridFrame, shipFrame) ) {
			[UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void) {
                                 recognizer.view.frame = shipFrame;
                             } 
                             completion:^(BOOL finished){
                                 [self checkGameBeginnable];
                             }];
		}
	}
}

- (void) rotateShipPiece:(UIRotationGestureRecognizer*)recognizer 
{
	if ( recognizer.state == UIGestureRecognizerStateBegan ) {
		[self.view bringSubviewToFront:recognizer.view];
	}
	else if ( recognizer.state == UIGestureRecognizerStateChanged ) {
		CGFloat rotation = recognizer.rotation;
		recognizer.view.transform = CGAffineTransformConcat(recognizer.view.transform, CGAffineTransformMakeRotation(rotation));
		recognizer.rotation = 0.0;
        
        [self checkGameBeginnable];
        
	}
	else if ( recognizer.state == UIGestureRecognizerStateEnded ) {
		// try to figure which right angle to snap to
		// calculation stolen from online forum somewhere
		CGFloat rotation = atan2(recognizer.view.transform.b, recognizer.view.transform.a);
		// round the rotation to a multiple of PI / 2, which is every 90 degrees
		CGFloat roundedRotation = M_PI_2 * round(rotation / M_PI_2);
		// animate it
		[UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void) {
                             recognizer.view.transform = CGAffineTransformMakeRotation(roundedRotation);
                         } 
                         completion:^(BOOL finished) {
                             [self checkGameBeginnable];
                         }];
	}
}

#pragma mark - UIPageControl

- (void) updatePageControlLabels 
{
	switch ( self.pageControl.currentPage ) {
		case 0:
			self.playerPageControlLabel.font = [UIFont boldSystemFontOfSize:self.playerPageControlLabel.font.pointSize];
			self.opponentPageControlLabel.font = [UIFont systemFontOfSize:self.opponentPageControlLabel.font.pointSize];
			break;
			
		case 1:
			self.playerPageControlLabel.font = [UIFont systemFontOfSize:self.playerPageControlLabel.font.pointSize];
			self.opponentPageControlLabel.font = [UIFont boldSystemFontOfSize:self.opponentPageControlLabel.font.pointSize];
			break;
	}
}

- (IBAction) changeGridPage:(UIPageControl*)sender 
{
	CGPoint offset = self.scrollView.contentOffset;
	offset.x = CGRectGetWidth(self.scrollView.frame) * sender.currentPage;
	[self.scrollView setContentOffset:offset animated:YES];
	[self updatePageControlLabels];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
	NSInteger page = round( scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame) );
	self.pageControl.currentPage = page;
	[self updatePageControlLabels];
}

#pragma mark - Sound Effects

- (SystemSoundID) explosionSound 
{
	if ( _explosionSound == 0 ) {
		NSURL* soundFileURL = [[NSBundle mainBundle] URLForResource:@"explosion" withExtension:@"caf"];
		// Create a system sound object representing the sound file
		AudioServicesCreateSystemSoundID( (CFURLRef)soundFileURL, &_explosionSound );
	}
	return _explosionSound;
}

- (SystemSoundID) splashSound 
{
	if ( _splashSound == 0 ) {
		NSURL* soundFileURL = [[NSBundle mainBundle] URLForResource:@"splash" withExtension:@"caf"];
		
		// Create a system sound object representing the sound file
		AudioServicesCreateSystemSoundID( (CFURLRef)soundFileURL, &_splashSound );
	}
	
	return _splashSound;
}

@end
