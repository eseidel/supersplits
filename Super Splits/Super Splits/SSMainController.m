//
//  SSMainController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMainController.h"
#import "SSMetroidFrame.h"
#import "SSRun.h"
#import "SSRunComparison.h"
#import "SSRunBuilder.h"
#import "SSSplit.h"
#import "SSWindowImageSource.h"

@implementation SSMainController

@synthesize runBuilder=_runBuilder, imageSource=_imageSource, lastFrame=_lastFrame, referenceRun=_referenceRun, runComparison=_runComparison;

-(id)init
{
    if (self = [super init]) {
        _imageSource = [[SSWindowImageSource alloc] init];
        _imageSource.delegate = self;
        _referenceRun = [[SSRun alloc] initWithContentsOfURL:[self referenceRunURL]];
        [self resetRun];
    }
    return self;
}

-(BOOL)running
{
    return [_imageSource polling];
}

-(void)startRun
{
    // FIXME: scansPerSecond should be a preference.
    double scansPerSecond = 10.0;
    [_imageSource startPollingWithInterval:(1.0 / scansPerSecond)];
}

-(void)stopRun
{
    [_imageSource stopPolling];
}

-(void)resetRun
{
    if ([self running])
        [self stopRun];
    _runComparison = [[SSRunComparison alloc] init];
    _runBuilder = [[SSRunBuilder alloc] init];
    _runComparison.runBuilder = _runBuilder;
    _runComparison.referenceRun = _referenceRun;
    _imageSource.start = nil;
}

-(NSURL *)referenceRunURL
{
    return [[self runsDirectoryURL] URLByAppendingPathComponent:@"reference.txt"];
}

// FIXME: This is a copy of SSRun autosaveDirectoryURL.
-(NSURL *)runsDirectoryURL
{
    NSString *runsPath = @"~/Library/Application Support/Super Splits/";
    runsPath = [runsPath stringByExpandingTildeInPath];
    NSURL *runsURL = [NSURL fileURLWithPath:runsPath];
    [[NSFileManager defaultManager] createDirectoryAtURL:runsURL withIntermediateDirectories:YES attributes:nil error:nil];
    return runsURL;
}

-(void)nextFrame:(CGImageRef)image atOffset:(NSTimeInterval)offset
{
    self.lastFrame = [[SSMetroidFrame alloc] initWithCGImage:image];
    if (!_lastFrame) {
        NSLog(@"Unsupported image!");
        return;
    }

    _runBuilder.offset = offset;
    if (_lastFrame.isMissingEnergyText) {
        _runBuilder.state = BlackScreenState;
    } else if (_lastFrame.isMostlyBlack) {
        _runBuilder.state = RoomTransitionState;
    } else if (_lastFrame.isItemScreen) {
        _runBuilder.state = ItemScreenState;
    } else {
        NSArray *previousSplits = [[_runBuilder run] roomSplits];
        NSUInteger previousSplitCount = [previousSplits count];

        _runBuilder.state = RoomState;
        // Important to set that we're in a room before we update the current map state.
        _runBuilder.mapState = _lastFrame.miniMapString;

        // When the "room number" changes, we invalidate our cached split indicies.
        if (previousSplits && previousSplitCount != [[[_runBuilder run] roomSplits] count])
            [_runComparison roomChanged];
        // Only update the reference cursors once we have a map for this room.
        if ([_runBuilder roomEntryMapState] && ![_runComparison haveSearchedForCurrentSplit])
            [_runComparison updateReferenceCursors];
    }
}

@end
