//
//  SSMainController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSImageSource.h"

@class SSMetroidFrame;
@class SSRun;
@class SSRunBuilder;
@class SSRunComparison;
@class SSWindowImageSource;
@class SSSplit;

@interface SSMainController : NSObject <SSImageSourceDelegate>

@property (strong) SSWindowImageSource *imageSource;
@property (readonly, getter=isRunning, nonatomic) BOOL running;
@property (strong) SSMetroidFrame *lastFrame;

@property (readonly, strong) SSRunBuilder *runBuilder;
@property (readonly, strong) SSRunComparison *runComparison;
@property (strong) SSRun *referenceRun;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

-(NSURL *)referenceRunURL;

// ImageSourceDelegate
-(void)nextFrame:(CGImageRef)image atOffset:(NSTimeInterval)offset;

@end
