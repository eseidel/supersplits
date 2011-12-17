//
//  SSMainController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSRun;
@class SSRunController;
@class SSWindowImageSource;
@class SSSplit;

@interface SSMainController : NSObject
{
    SSRunController *_runController;
    SSRun *_referenceRun;
    SSWindowImageSource *_imageSource;

    NSUInteger _currentReferenceSplitIndex; // Reference for current room.
    NSUInteger _previousReferenceSplitIndex; // Reference for the previous room.
    NSUInteger _lastMatchedReferenceSplitIndex; // Last room we successfully matched a reference for.
    NSUInteger _lastSearchedSplitIndex;

    NSImageView *_debugImageView;
}

@property (readonly) BOOL running;
@property (readonly) SSRunController *runController;
@property (retain) SSRun *referenceRun;
@property (retain) NSImageView *debugImageView;
@property (readonly) NSNumber *lastMatchedSplitNumber;

-(NSURL *)referenceRunURL;
-(NSURL *)runsDirectoryURL;

-(void)resetRun;
-(void)startRun;
-(void)stopRun;

-(SSSplit *)currentSplitReference;
-(SSSplit *)previousSplitReference;

-(NSNumber *)deltaToStartOfCurrentRoom;
-(NSNumber *)deltaForPreviousSplit;

@end

