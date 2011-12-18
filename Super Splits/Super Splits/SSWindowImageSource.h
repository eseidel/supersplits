//
//  SNESImageSource.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SSImageSourceDelegate)
-(void)nextFrame:(CGImageRef)frame;
@end


@interface SSWindowImageSource : NSObject
{
    CGWindowID _windowID;
	NSTimer *_timer;
    NSObject *_delegate;
}

@property (retain) NSObject *delegate;
@property (readonly) BOOL polling;

-(BOOL)startPollingWithInterval:(NSTimeInterval)interval;
-(void)stopPolling;

-(CGWindowID)findSNESWindowId;

@end
