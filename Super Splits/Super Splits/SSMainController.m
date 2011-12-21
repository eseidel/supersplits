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
    [_imageSource startPolling];
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
    return [SSRun defaultURLForRunWithName:@"reference"];
}

-(void)nextFrame:(CGImageRef)image atOffset:(NSTimeInterval)offset
{
    self.lastFrame = [[SSMetroidFrame alloc] initWithCGImage:image];
    if (!_lastFrame) {
        NSLog(@"Unsupported image!");
        return;
    }

    NSArray *previousSplits = [[_runBuilder run] roomSplits];
    NSUInteger previousSplitCount = [previousSplits count];

    [_runBuilder updateWithFrame:_lastFrame atOffset:offset];

    // FIXME: This logic could all be done via some KVO between RunComparison and RunBuilder.
    // When the "room number" changes, we invalidate our cached split indicies.
    if (previousSplits && previousSplitCount != [[[_runBuilder run] roomSplits] count])
        [_runComparison roomChanged];
    // Only update the reference cursors once we have a map for this room.
    if ([_runBuilder roomEntryMapState] && ![_runComparison haveSearchedForCurrentSplit])
        [_runComparison updateReferenceCursors];
}

@end
