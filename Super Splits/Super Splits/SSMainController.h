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
#import "SNESImageSource.h"

@interface SSMainController : NSObject
{
    BOOL _running;  // FIXME: This is just an alias for (BOOL)_timer

    SSRun *_run;
    SNESImageSource *_imageSource;
    SSImageProcessor *_imageProcessor;

    NSImageView *_debugImageView;
}

@property BOOL running;
@property (readonly) SSRun *currentRun;
@property (retain) NSImageView *debugImageView;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

@end

