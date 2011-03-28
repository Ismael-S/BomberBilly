//
//  Animation.h
//  BomberBilly
//
//  Created by Ruud van Falier on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnimationSequence.h"

@interface Animation : NSObject {
	NSMutableDictionary* sequences;
	CGRect maximumFrameSize;
	NSString* currentSequence;
	NSString* spriteSheetFileName;
	NSString* tileSheetFileName;
	float scale;
    float rotation;
}

@property (nonatomic, retain) NSString* spriteSheetFileName;
@property (nonatomic, retain) NSString* tileSheetFileName;
@property (nonatomic, retain) NSString* currentSequence;
@property (readonly) int width;
@property (readonly) int height;
@property (readonly) int sequenceWidth;
@property (readonly) int sequenceHeight;
@property float scale;
@property float rotation;

- (Animation*) initForSprite:(NSString*)spriteSheetFile;
- (Animation*) initForTile:(int)tileNumber;
- (void) setSequence:(NSString*)sequence;
- (AnimationSequence*) get;
- (CGRect) getMaximumFrameSize;

@end
