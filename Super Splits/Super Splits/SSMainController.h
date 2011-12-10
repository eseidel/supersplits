//
//  SSMainController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSRunController.h"
#import "SSImageProcessor.h"
#import "SSWindowImageSource.h"

@interface SSMainController : NSObject
{
    SSRunController *_run;
    SSRunController *_referenceRun;
    SSWindowImageSource *_imageSource;
    SSImageProcessor *_imageProcessor;

    NSImageView *_debugImageView;
}

@property (readonly) BOOL running;
@property (readonly) SSRunController *currentRun;
@property (readonly) SSRunController *referenceRun;
@property (retain) NSImageView *debugImageView;

-(NSURL *)referenceRunURL;
-(NSURL *)runsDirectoryURL;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

@end

