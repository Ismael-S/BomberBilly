//
//  GameState.m
//  BomberBilly
//
//  Created by Ruud van Falier on 19/01/11.
//  Copyright 2011 DotTech. All rights reserved.
//

#import "GameState.h"
#import "Constants.h"

// TODO: TouchIsInsideRect method

@implementation GameState

@synthesize gameStateManager;
@synthesize fps;
@synthesize touching;
@synthesize touchPosition;

#pragma mark -
#pragma mark Methods

- (id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)manager
{
	CLog();
	if (self = [super initWithFrame:frame])
	{
		self.gameStateManager = manager;
		self.userInteractionEnabled = true;
	}
	return self;
}


- (void) dealloc
{
	[super dealloc];
}


- (void) render
{
}


- (void) update:(float)gameTime
{
}


- (void) handleTouch
{
}


- (void) updateFps
{
	CLogGL();
	
	double currTime = [[NSDate date] timeIntervalSince1970];
	fpsFramesThisSecond++;
	
	float timeThisSecond = currTime - fpsLastSecondStart;
	if (timeThisSecond > 1.0f) {
		CLogGLU();
		self.fps = fpsFramesThisSecond;
		fpsFramesThisSecond = 0;
		fpsLastSecondStart = currTime;
	}
}


- (void) drawRect:(CGRect)rect
{
}


#pragma mark -
#pragma mark Catch touch events

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self catchTouch:touches];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	[self catchTouch:touches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.touching = NO;
}

- (void) catchTouch:(NSSet*)touches
{
	UITouch* touch = [touches anyObject];
	self.touchPosition = [touch locationInView:self];
	self.touching = YES;
	
	// Touch position starts in the upperleft corner.
	// This is opposite to the OpenGL draw position that starts in the bottomleft corner.
	touchPosition.y = SCREEN_HEIGHT - touchPosition.y;
}

@end
