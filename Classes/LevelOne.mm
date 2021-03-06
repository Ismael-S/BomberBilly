//
//  LevelOne.m
//  BomberBilly
//
//  Created by Ruud van Falier on 3/14/11.
//  Copyright 2011 DotTech. All rights reserved.
//

#import "LevelOne.h"

@implementation LevelOne


- (LevelOne*) init
{
	CLog();
	self = [super init];
	
	self.startBombs = 0;
	self.heroSpawnPoint = CGPointMake(20, 480);
	
	return self;
}


- (Tile**) getTilesData:(World*)world progressCallback:(Callback)callback
{
	CLog();
    
    // DrawingFlag values
    // 0:dfDrawNothing, 1:dfIndestructibleBlock, 2:dfDestructibleBlock, 3:dfJumpBlock, 4:dfDynamite, 5:dfSpikes
    // 6:dfExitDoor, 7:dfElevator, 8:dfSwitch
	int drawData[13][10] = {
		{ 0, 0, 4, 0, 2, 4, 4, 0, 0, 0 },
		{ 1, 1, 2, 2, 1, 1, 1, 2, 1, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 4, 0, 5, 5, 0, 0, 0, 0, 0 },
		{ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 1, 1, 1, 3, 5, 1, 0 },
		{ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 1, 1, 2, 1, 1, 1, 7 },
		{ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
		{ 0, 4, 0, 1, 1, 2, 0, 0, 1, 1 },
		{ 0, 1, 1, 1, 0, 0, 2, 0, 0, 6 },
		{ 7, 1, 1, 1, 1, 3, 5, 1, 1, 1 }
	};
	
    // PhysicFlag values
    // 0:pfNoTile, 1:pfIndestructibleTile, 2:pfDestructibleTile, 3:pfJumpTile, 4:pfBombTile, 5:pfDeadlyTile
    // 6:pfFinishTile, 7:pfElevatorTile, 8:pfSwitchTile
	int physicsData[13][10] = {
		{ 0, 0, 4, 0, 2, 4, 4, 0, 0, 0 },
		{ 1, 1, 2, 2, 1, 1, 1, 2, 1, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 4, 0, 5, 5, 0, 0, 0, 0, 0 },
		{ 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 1, 1, 1, 3, 5, 1, 0 },
		{ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 1, 1, 2, 1, 1, 1, 7 },
		{ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
		{ 0, 4, 0, 1, 1, 2, 0, 0, 1, 1 },
		{ 0, 1, 1, 1, 0, 0, 2, 0, 0, 6 },
		{ 7, 1, 1, 1, 1, 3, 5, 1, 1, 1 }
	};
	
	// Create the tile objects
	return [self createTilesLayer:world physicsData:physicsData drawingData:drawData switchesParams:NULL progressCallback:callback];
}


- (Entity**) getEnemyData:(World*)world
{
	CLog();
	self.enemyCount = 1;
	Enemy** enemies = new Enemy*[self.enemyCount];
	
	for (int i=0; i<self.enemyCount; i++) {
		enemies[i] = [[Enemy alloc] initWithWorld:world];
	}
	
	enemies[0].x = 290;
	enemies[0].y = 192;
	
	return enemies;
}

@end
