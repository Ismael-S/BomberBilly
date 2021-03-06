//
//  World.h
//  BomberBilly
//
//  Created by Ruud van Falier on 2/23/11.
//  Copyright 2011 DotTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Tile.h"
#import "Sprite.h"

@class Level;

typedef enum {
	Up = 0,
	Down = 1,
	Left = 2,
	Right = 3,
    None = 4
} Direction;


@interface World : NSObject
{
@private
    int currentLevelIndex;
    int backgroundOffset;
    int lastUpdateTime;
}

@property Tile** tilesLayer;
@property Sprite** enemies;
@property Level** levels;
@property (readonly) Level* currentLevel;

- (void) loadLevel:(int)index progressCallback:(Callback)callback;
- (Tile*) nearestPlatform:(Sprite*)sprite inDirection:(Direction)direction;
- (Tile**) platformsToBomb:(Sprite*)sprite;
- (void) update:(float)gameTime;
- (void) draw;
- (void) drawBackground;
- (void) drawDebugMessage;

#if DEBUG_TILE_DETECTION
- (Tile*) DEBUG_nearestPlatform:(CGPoint)spriteLocation inDirection:(Direction)direction isFlipped:(BOOL)flipped;
#endif


@end
