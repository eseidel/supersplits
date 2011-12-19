//
//  SSMainController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSMetroidFrame;
@class SSRun;
@class SSRunBuilder;
@class SSRunComparison;
@class SSWindowImageSource;
@class SSSplit;

@interface SSMainController : NSObject

@property (retain) SSWindowImageSource *imageSource;
@property (readonly) BOOL running;
@property (retain) SSMetroidFrame *lastFrame;

@property (readonly, retain) SSRunBuilder *runBuilder;
@property (readonly, retain) SSRunComparison *runComparison;
@property (retain) SSRun *referenceRun;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

-(NSURL *)referenceRunURL;
-(NSURL *)runsDirectoryURL;

// ImageSourceDelegate
-(void)nextFrame:(CGImageRef)image atOffset:(NSTimeInterval)offset;

@end
