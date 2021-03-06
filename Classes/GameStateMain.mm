//
//  GameStateSpriteTest.m
//  BomberBilly
//
//  Created by Ruud van Falier on 2/16/11.
//  Copyright 2011 DotTech. All rights reserved.
//

#import "GameStateMain.h"
#import "GameStateGameOver.h"
#import "Level.h"

// TODO: 
// - Somehow the "Loading..." text is not being displayed when initGameObjects is called for the first time

@implementation GameStateMain

@synthesize world;
@synthesize hero;
@synthesize currentLevel;

- (GameStateMain*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)manager
{
	CLog();
	if ((self = [super initWithFrame:frame andManager:manager])) 
	{
		// Create game world. We only need to initialize it once!
		self.world = [[World alloc] init];
		
        // Set the starting level (levels are defined in World.mm)
        // Note: index 0 is the tile debugging level
        //       index 1 is the tutorial level
        // So the actual game levels start at index 2
		self.currentLevel = 5; //LEVELINDEX_PLAYLEVELS_START;
        #if DEBUG_TILE_DETECTION
            self.currentLevel = LEVELINDEX_DEBUGTILES;
        #endif

		// Initialize game objects for the first time
		// We'll do this every time we (re)start a level
		[self initGameObjects:@selector(loadingStatusUpdate:)];
		
		// Give the hero some lifes
		self.hero.lifes = lifes = HERO_START_LIFES;
	}
	return self;
}


- (void) dealloc
{
	CLog();
	[hero release];
	[world release];
	[super dealloc];
}


#pragma mark -
#pragma mark Game objects initialization

- (void) loadingStatusUpdate:(NSNumber*)percentageDone
{
	CLog();
	
    if ([percentageDone intValue] % 10 == 0)
    {
        glClear(GL_COLOR_BUFFER_BIT);
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        
        [resManager.fontMessage drawString:[NSString stringWithFormat:@"Loading... [%d%%]", [percentageDone intValue]] atPoint:CGPointMake(75, 220)];
        NSLog(@"Loading... [%d%%]", [percentageDone intValue]);
        
        [self swapBuffers];
    }
}


// Allocate and initialize all game objects (level definition, tiles, sprites)
// callback is invoked during the initialization to keep us informed about the progress
- (void) initGameObjects:(SEL)callback
{
	CLog();
	[self.world loadLevel:currentLevel progressCallback:CallbackCreate(self, callback)];
	
	// Initialize our hero
	self.hero = [[Hero alloc] initWithWorld:self.world];
	self.hero.offScreen = NO;
	self.hero.x = self.world.currentLevel.heroSpawnPoint.x;
	self.hero.y = self.world.currentLevel.heroSpawnPoint.y;
	self.hero.walkTowardsX = 0;
	self.hero.flipped = NO;
	self.hero.world = self.world;
	self.hero.bombs = self.world.currentLevel.startBombs;
    
    touchedTile = NULL;
    
    #if DEBUG_TILE_DETECTION
        self.hero.offScreen = (self.hero.x < 0 || self.hero.x > SCREEN_WIDTH || self.hero.y < 0 || self.hero.y > SCREEN_HEIGHT);
    #endif
}


#pragma mark -
#pragma mark Game state update handlers

- (void) update:(float)gameTime
{
	CLogGL();
	[self updateFps];
	
	if (!restarting)
	{
        if (![self blinkSwitchTarget:gameTime]) {
            // Touch is only handled if we're not touching a switch tile
            [self handleTouch];
        }
        
		[self.world update:gameTime];
		[self.hero update:gameTime];
		
		// Check if hero is dead and has lifes left
		// Then either restart level or show gameover screen
		[self handleHeroDeath];
		
		// Check if hero reached the finish
		finished = (self.hero.state == HeroDoneCheering);
	}
}


- (void) render
{
    [self render:YES];
}


- (void) render:(BOOL)swapBuffer
{
	CLogGL();
	
	// Clear anything left over from the last frame, and set background color.
	glClear(GL_COLOR_BUFFER_BIT);
    
	if (!restarting)
	{
		if (!gameOver && !finished)
		{
			// Draw world
			[self.world draw];
			
			// Draw hero sprite
			[self.hero draw];
            
			// Draw text data (bomb/life count)
			[resManager.fontGameInfo drawString:[NSString stringWithFormat:@"%d", self.hero.bombs] atPoint:CGPointMake(113, 5)];
			[resManager.fontGameInfo drawString:[NSString stringWithFormat:@"%d", self.hero.lifes] atPoint:CGPointMake(268, 5)];
			if (DEBUG_SHOW_FPS) {
                [resManager.fontGameInfo drawString:[NSString stringWithFormat:@"FPS:%d", self.fps] atPoint:CGPointMake(130, 5)];
			}
		}
		else if (gameOver) {
			// We're game over... change gamestate and end the game
			[self.gameStateManager changeGameState:[GameStateGameOver class]];
			return;
		}
		else if (finished) {
			// Move on to the next level
			[self restartLevel:YES];
			return;
		}
	}
	
	// Swap working buffer to active buffer
    if (swapBuffer) {
        [self swapBuffers];
    }
}


- (void) handleTouch
{
	CLogGL();
    
    if (self.touching)
    {
        if (self.touchPosition.y > SCREEN_HEIGHT - SCREEN_WORLD_HEIGHT)
        {
            // World area is being touched
            // If we are not jumping, falling or dying then we walk
            if (self.hero.state != HeroJumping && self.hero.state != HeroFalling && 
                self.hero.state != HeroDying && self.hero.state != HeroReachedFinish) 
            {
                if (self.touchPosition.x <= SCREEN_WIDTH / 2) {
                    self.hero.walkTowardsX = 0;
                }
                else {
                    self.hero.walkTowardsX = 319;
                }
                self.hero.state = HeroWalking;
            }
        }
        else 
        {
            // Control panel is being touched
            if ((self.touchPosition.x >= BOMB_BUTTON.origin.x && self.touchPosition.x <= BOMB_BUTTON.origin.x + BOMB_BUTTON.size.width) &&
                (SCREEN_HEIGHT - self.touchPosition.y >= BOMB_BUTTON.origin.y && SCREEN_HEIGHT - self.touchPosition.y <= BOMB_BUTTON.origin.y + BOMB_BUTTON.size.height))
            {
                if (gameOver) {
                    currentLevel = 0;
                    gameOver = NO;
                    lifes = 2;
                    [self restartLevel:NO];
                }
                
                // Bomb button is being touched
                if (self.hero.state == HeroIdle) {
                    self.hero.state = HeroDroppingBomb;
                }
            }
            else if ((self.touchPosition.x >= KILL_BUTTON.origin.x && self.touchPosition.x <= KILL_BUTTON.origin.x + KILL_BUTTON.size.width) &&
                (SCREEN_HEIGHT - self.touchPosition.y >= KILL_BUTTON.origin.y && SCREEN_HEIGHT - self.touchPosition.y <= KILL_BUTTON.origin.y + KILL_BUTTON.size.height))
            {
                // Suicide button is being touched
                self.hero.state = HeroDying;
            }
        }
    }
    else
    {
        if (self.hero.state == HeroJumping) {
            self.hero.state = HeroFalling;
        }
        else if (self.hero.state != HeroFalling && self.hero.state != HeroDying && self.hero.state != HeroReachedFinish) {
            self.hero.state = HeroIdle;
        }
        
        // It's important to set WalkTowardsX to -1 otherwise hero will always
        // try to move to that coordinate during falls
        self.hero.walkTowardsX = -1;
    }
}


- (void) restartLevel:(BOOL)moveToNextLevel
{
	CLog();
	restarting = YES;
	
	if (moveToNextLevel) 
	{
		self.currentLevel++;
		if (self.currentLevel >= NUMBER_OF_LEVELS) {
			// Finished the game
			// TODO: Implement ending
			NSLog(@"Game finished");
			self.currentLevel = LEVELINDEX_PLAYLEVELS_START;
		}
	}
	
	[hero release];
	[self initGameObjects:@selector(loadingStatusUpdate:)];
    
	self.hero.lifes = lifes;
    
	finished = NO;
	restarting = NO;
}


- (void) handleHeroDeath
{
	CLogGL();
	
	if (self.hero.state == HeroDead) 
	{
		lifes--;
		self.hero.lifes = lifes;
		if (self.hero.lifes > 0) {
			[self restartLevel:NO];
		}
		else {
			gameOver = YES;
		}
	}
}


- (BOOL) blinkSwitchTarget:(float)gameTime
{
    if (self.touching && touchedTile == NULL)
    {
        if (self.touchPosition.y > SCREEN_HEIGHT - SCREEN_WORLD_HEIGHT)
        {
            int touchingDataRow = floor((double)(SCREEN_HEIGHT - self.touchPosition.y) / TILE_HEIGHT);
            int touchingDataColumn = floor((double)(self.touchPosition.x / TILE_WIDTH));
            int tileIndex = CoordsToIndex(touchingDataColumn, touchingDataRow);
            touchedTile = [self.world.tilesLayer[tileIndex] retain];
            
            // Make switch target tiles blink
            if (touchedTile.physicsFlag == pfSwitchTile) 
            {
                SwitchTile* switchTile = (SwitchTile*)touchedTile;
                for (int i=0; i<switchTile.targetsCount; i++) {  
                    [switchTile.targets[i] startTileBlinking:NO];
                }
                
                blinkStartTime = gameTime * 1000;               
                return YES;
            }
        }
    }
    else if (touchedTile != NULL)
    {
        if (gameTime * 1000 > blinkStartTime + SWITCH_TARGETMARKER_DURATION * 1000)
        {
            // Stop switch target tiles blink
            if (touchedTile.physicsFlag == pfSwitchTile) 
            {
                SwitchTile* switchTile = (SwitchTile*)touchedTile;
                for (int i=0; i<switchTile.targetsCount; i++) {  
                    [switchTile.targets[i] stopTileBlinkingDone:NO];
                }
            }
            
            [touchedTile release];
            touchedTile = NULL;
        }
        
        return YES;
    }
    
    return NO;
}

@end
