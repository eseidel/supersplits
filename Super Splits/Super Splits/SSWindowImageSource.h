//
//  SNESImageSource.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSImageSource.h"

@interface SSWindowImageSource : SSImageSource
{
    CGWindowID _windowID;
	NSTimer *_timer;

    double _speedMultiplier;
}

@property (readonly) BOOL polling;
@property (retain) NSDate *start;
@property (nonatomic) double speedMultiplier;

-(BOOL)startPollingWithInterval:(NSTimeInterval)interval;
-(void)stopPolling;

-(CGWindowID)findSNESWindowId;

@end
