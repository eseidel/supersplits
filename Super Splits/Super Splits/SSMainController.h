//
//  SSMainController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSRun.h"

@interface SSMainController : NSObject
{
    CGWindowID _windowID;
	NSTimer *_timer;

    BOOL _running;  // FIXME: This is just an alias for (BOOL)_timer

    SSRun *_run;
}

@property BOOL running;
@property (readonly) SSRun *currentRun;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

-(CGWindowID)findSNESWindowId;

-(CGPoint)findMapCenter:(CGImageRef)frame;
-(CGRect)findEnergyText:(CGImageRef)frame;
-(BOOL)isTransitionScreen:(CGImageRef)image;

@end

