//
//  SSMainController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSRunController;
@class SSWindowImageSource;
@class SSSplit;

@interface SSMainController : NSObject
{
    SSRunController *_run;
    SSRunController *_referenceRun;
    SSWindowImageSource *_imageSource;

    NSUInteger _currentReferenceSplitIndex; // Reference for current room.
    NSUInteger _previousReferenceSplitIndex; // Reference for the previous room.
    NSUInteger _lastMatchedReferenceSplitIndex; // Last room we successfully matched a reference for.

    NSImageView *_debugImageView;
}

@property (readonly) BOOL running;
@property (readonly) SSRunController *currentRun;
@property (retain) SSRunController *referenceRun;
@property (retain) NSImageView *debugImageView;

-(NSURL *)referenceRunURL;
-(NSURL *)runsDirectoryURL;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

-(SSSplit *)currentSplitReference;
-(SSSplit *)previousSplitReference;

-(NSNumber *)deltaAfterPreviousSplit;
-(NSNumber *)deltaForPreviousSplit;

@end

