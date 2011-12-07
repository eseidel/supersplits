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

    NSDate *_overallStart;
    NSDate *_roomStart;
    NSDate *_transitionStart;

    NSMutableArray *_roomSplits;
}

-(void)startRun;
-(void)startRoom;
-(BOOL)inTransition;
-(void)startTransition;
-(void)endTransition;

-(NSNumber *)lastRoomSplit;
-(NSNumber *)roomTime;
-(NSNumber *)totalTime;

-(CGWindowID)findSNESWindowId;
-(BOOL)isTransitionScreen:(CGImageRef)image;

@end

