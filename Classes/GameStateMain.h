//
//  GameStateSpriteTest.h
//  BomberBilly
//
//  Created by Ruud van Falier on 2/16/11.
//  Copyright 2011 DotTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionManager.h>
#import "ResourceManager.h"
#import "GLESGameState.h"

#import "Sprite.h"
#import "Tile.h"
#import "ElevatorTile.h"
#import "SwitchTile.h"
#import "Hero.h"
#import "World.h"

@interface GameStateMain : GLESGameState
{
@private
    Tile* touchedTile;
    BOOL restarting;
    BOOL gameOver;
    BOOL finished;
    int lifes;
    float blinkStartTime;
}

@property (nonatomic, retain) World* world;
@property (nonatomic, retain) Hero* hero;
@property int currentLevel;

- (void) initGameObjects:(SEL)callback;
- (void) render:(BOOL)swapBuffer;
- (void) loadingStatusUpdate:(NSNumber*)percentageDone;
- (void) restartLevel:(BOOL)moveToNextLevel;
- (void) handleHeroDeath;
- (BOOL) blinkSwitchTarget:(float)gameTime;

@end
