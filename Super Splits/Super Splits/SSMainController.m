//
//  SSMainController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMainController.h"
#import "SSMetroidFrame.h"
#import "SSRunController.h"
#import "SSRun.h"
#import "SSSplit.h"
#import "SSWindowImageSource.h"

@interface SSMainController (PrivateMethods)

-(BOOL)_haveSearchedForCurrentSplit;
-(void)_updateReferenceCursors;

@end


@implementation SSMainController

@synthesize runController=_runController, referenceRun=_referenceRun, lastFrame=_lastFrame;

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
    _runController = [[SSRunController alloc] init];
    _previousReferenceSplitIndex = kInvalidSplitIndex;
    _currentReferenceSplitIndex = kInvalidSplitIndex;
    _lastMatchedReferenceSplitIndex = kInvalidSplitIndex;
    _lastSearchedSplitIndex = kInvalidSplitIndex;
    _imageSource.start = nil;
}

-(NSURL *)referenceRunURL
{
    return [[self runsDirectoryURL] URLByAppendingPathComponent:@"reference.txt"];
}

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

    if (_lastFrame.isMissingEnergyText) {
        _runController.state = BlackScreenState;
    } else if (_lastFrame.isMostlyBlack) {
        _runController.state = RoomTransitionState;
    } else if (_lastFrame.isItemScreen) {
        _runController.state = ItemScreenState;
    } else {
        NSArray *previousSplits = [[_runController currentRun] roomSplits];
        NSUInteger previousSplitCount = [previousSplits count];

        _runController.state = RoomState;
        // Important to set that we're in a room before we update the current map state.
        _runController.mapState = _lastFrame.miniMapString;

        if (previousSplits && previousSplitCount != [[[_runController currentRun] roomSplits] count]) {
            // We must have added a split, move our reference indexes back one.
            _previousReferenceSplitIndex = _currentReferenceSplitIndex;
            _currentReferenceSplitIndex = kInvalidSplitIndex;
        }
        // Only update the reference cursors once we have a map for this room.
        if ([_runController roomEntryMapState] && ![self _haveSearchedForCurrentSplit])
            [self _updateReferenceCursors];
    }
}

// FIXME: All this reference finding logic could instead be triggered when
// currentRoomNumber changes.
-(BOOL)_haveSearchedForCurrentSplit
{
    if (_lastSearchedSplitIndex == kInvalidSplitIndex)
        return NO;
    return _lastSearchedSplitIndex >= [[[_runController currentRun] roomSplits] count];
}

-(void)_updateReferenceCursors
{
    assert(![self _haveSearchedForCurrentSplit]);
    if (![[_referenceRun roomSplits] count])
        return;

    // This number controls how many splits in the reference room we would ever
    // skip when looking for a room.  If our room detection was perfect, we could
    // set this to inifinity and be fine, but since our room detection is crude
    // and there are thus duplicate mapstates during the run, we use a small value.
    const NSUInteger scanLimit = 6;

    // This should probably use _run._roomEntryMapState, but we know we
    // just set the mapState so use that for now.
    NSString *mapState = _runController.mapState;
    _currentReferenceSplitIndex = [_referenceRun indexOfFirstSplitAfter:_lastMatchedReferenceSplitIndex withEntryMap:mapState scanLimit:scanLimit];
    _lastSearchedSplitIndex = [[[_runController currentRun] roomSplits] count];
    if (_currentReferenceSplitIndex == kInvalidSplitIndex)
        return;
    _lastMatchedReferenceSplitIndex = _currentReferenceSplitIndex;
}

-(NSNumber *)lastMatchedSplitNumber
{
    if (_lastMatchedReferenceSplitIndex == kInvalidSplitIndex)
        return nil;
    return [NSNumber numberWithInteger:_lastMatchedReferenceSplitIndex + 1];
}

-(SSSplit *)currentSplitReference
{
    if (_currentReferenceSplitIndex == kInvalidSplitIndex)
        return nil;
    return [[_referenceRun roomSplits] objectAtIndex:_currentReferenceSplitIndex];
}

-(SSSplit *)previousSplitReference
{
    if (_previousReferenceSplitIndex == kInvalidSplitIndex)
        return nil;
    return [[_referenceRun roomSplits] objectAtIndex:_previousReferenceSplitIndex];
}

-(NSNumber *)deltaToStartOfCurrentRoom
{
    NSNumber *referenceTimeAfterLastRoom = nil;
    if (_previousReferenceSplitIndex != kInvalidSplitIndex)
        referenceTimeAfterLastRoom = [_referenceRun timeAfterSplitAtIndex:_previousReferenceSplitIndex];
    else if (_currentReferenceSplitIndex != kInvalidSplitIndex) {
        // If we don't have a previous split (the last room was confused)
        // but we do know what this room is, then we compute the time
        // up until this room from the reference.
        referenceTimeAfterLastRoom = [_referenceRun timeAfterSplitAtIndex:_currentReferenceSplitIndex - 1];
    } else
        return nil;

    SSRun *run = [_runController currentRun];
    NSNumber *timeAfterLastRoom = [run timeAfterSplitAtIndex:([[run roomSplits] count] - 1)];
    NSTimeInterval deltaAfterLastRoom = [timeAfterLastRoom doubleValue] - [referenceTimeAfterLastRoom doubleValue];
    return [NSNumber numberWithDouble:deltaAfterLastRoom];
}

-(NSNumber *)deltaForPreviousSplit
{
    if (_previousReferenceSplitIndex == kInvalidSplitIndex)
        return nil;

    NSNumber *previousSplitReferenceDuration = [[self previousSplitReference] duration];
    SSRun *run = [_runController currentRun];
    SSSplit *previousSplit = [[run roomSplits] lastObject];
    NSNumber *previousSplitDuration = [previousSplit duration];

    NSTimeInterval deltaForPreviousSplit = [previousSplitDuration doubleValue] - [previousSplitReferenceDuration doubleValue];
    return [NSNumber numberWithDouble:deltaForPreviousSplit];
}

@end
