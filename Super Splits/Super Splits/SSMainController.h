//
//  SSMainController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSMainController : NSObject
{
    CGWindowID _windowID;
	NSTimer *_timer;

    BOOL _running;  // FIXME: This is just an alias for (BOOL)_timer

    NSDate *_overallStart;
    NSDate *_roomStart;
    NSDate *_transitionStart;

    NSMutableArray *_roomSplits;
}

@property BOOL running;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

-(void)startRoom;
-(BOOL)inTransition;
-(void)startTransition;
-(void)endTransition;

-(NSNumber *)lastRoomSplit;
-(NSNumber *)roomTime;
-(NSNumber *)totalTime;

-(CGWindowID)findSNESWindowId;
-(CGPoint)findMapCenter:(CGImageRef)frame;
-(BOOL)isTransitionScreen:(CGImageRef)image;

@end

