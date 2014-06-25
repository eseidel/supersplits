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

-(id)init
{
    self = [super init];
    if (self) {
        _imageSource = [[SSWindowImageSource alloc] init];
        _imageSource.delegate = self;
        _referenceRun = [[SSRun alloc] initWithContentsOfURL:[self referenceRunURL]];
        [self resetRun];
    }
    return self;
}

-(BOOL)isRunning
{
    return [_imageSource isPolling];
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
    if ([self isRunning])
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
    NSString *prevousEntryMapState = _runBuilder.currentSplit.entryMapState;

    [_runBuilder updateWithFrame:_lastFrame atOffset:offset];

    // FIXME: This logic could all be done via some KVO between RunComparison and RunBuilder.
    // When the "room number" changes, we invalidate our cached split indicies.
    BOOL splitsChanged = previousSplits && previousSplitCount != [[[_runBuilder run] roomSplits] count];
    BOOL mapChanged = prevousEntryMapState != _runBuilder.currentSplit.entryMapState;
    if (splitsChanged || mapChanged)
        [_runComparison _updateMatchedSplits];
}

@end
