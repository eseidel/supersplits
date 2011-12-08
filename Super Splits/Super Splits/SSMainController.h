//
//  SSMainController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSRun.h"
#import "SSImageProcessor.h"

@interface SSMainController : NSObject
{
    CGWindowID _windowID;
	NSTimer *_timer;

    BOOL _running;  // FIXME: This is just an alias for (BOOL)_timer

    SSRun *_run;
    SSImageProcessor *_imageProcessor;
}

@property BOOL running;
@property (readonly) SSRun *currentRun;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

-(CGWindowID)findSNESWindowId;

@end

