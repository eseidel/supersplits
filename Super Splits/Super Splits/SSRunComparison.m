//
//  SSRunComparison.m
//  Super Splits
//
//  Created by Eric Seidel on 12/19/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRunComparison.h"
#import "SSRun.h"
#import "SSRunBuilder.h"
#import "SSSplit.h"

@interface SSRunComparison (PrivateMethods)

-(NSInteger)_currentSplitIndex;
-(NSInteger)_previousSplitIndex;
-(SSSplit *)_previousSplit;

@end

@implementation SSRunComparison

@synthesize runBuilder=_runBuilder, referenceRun=_referenceRun;

-(id)init
{
    if (self = [super init]) {
        _previousReferenceSplitIndex = kInvalidSplitIndex;
        _currentReferenceSplitIndex = kInvalidSplitIndex;
        _lastMatchedReferenceSplitIndex = kInvalidSplitIndex;
        _lastSearchedSplitIndex = kInvalidSplitIndex;
    }
    return self;
}

// FIXME: All this reference finding logic could instead be triggered when
// currentRoomNumber changes.
-(BOOL)haveSearchedForCurrentSplit
{
    if (_lastSearchedSplitIndex == kInvalidSplitIndex)
        return NO;
    return _lastSearchedSplitIndex >= [self _currentSplitIndex];
}

-(void)roomChanged
{
    // We must have added a split, move our reference indexes back one.
    _previousReferenceSplitIndex = _currentReferenceSplitIndex;
    _currentReferenceSplitIndex = kInvalidSplitIndex;

    // FIXME: This doesn't really belong here, but currently room names
    // are held off the reference splits and this is the only class
    // that knows the mapping between current and refernece splits.
    SSSplit *previousSplitReference = [self previousSplitReference];
    if (previousSplitReference)
        [self _previousSplit].roomName = previousSplitReference.roomName;
}

-(void)updateReferenceCursors
{
    assert(![self haveSearchedForCurrentSplit]);
    if (![[_referenceRun roomSplits] count])
        return;

    // This number controls how many splits in the reference room we would ever
    // skip when looking for a room.  If our room detection was perfect, we could
    // set this to inifinity and be fine, but since our room detection is crude
    // and there are thus duplicate mapstates during the run, we use a small value.
    const NSUInteger scanLimit = 6;

    // This should probably use _run._roomEntryMapState, but we know we
    // just set the mapState so use that for now.
    NSString *mapState = _runBuilder.mapState;
    _currentReferenceSplitIndex = [_referenceRun indexOfFirstSplitAfter:_lastMatchedReferenceSplitIndex withEntryMap:mapState scanLimit:scanLimit];
    _lastSearchedSplitIndex = [self _currentSplitIndex];
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

    NSNumber *timeAfterLastRoom = [[_runBuilder run] timeAfterSplitAtIndex:[self _previousSplitIndex]];
    NSTimeInterval deltaAfterLastRoom = [timeAfterLastRoom doubleValue] - [referenceTimeAfterLastRoom doubleValue];
    return [NSNumber numberWithDouble:deltaAfterLastRoom];
}

-(NSInteger)_currentSplitIndex
{
    return [[[_runBuilder run] roomSplits] count];
}

-(NSInteger)_previousSplitIndex
{
    return [self _currentSplitIndex] - 1;
}

-(SSSplit *)_previousSplit
{
    return [[[_runBuilder run] roomSplits] lastObject];
}

-(NSNumber *)deltaForPreviousSplit
{
    if (_previousReferenceSplitIndex == kInvalidSplitIndex)
        return nil;

    NSNumber *previousSplitReferenceDuration = [[self previousSplitReference] duration];
    NSNumber *previousSplitDuration = [[self _previousSplit] duration];

    NSTimeInterval deltaForPreviousSplit = [previousSplitDuration doubleValue] - [previousSplitReferenceDuration doubleValue];
    return [NSNumber numberWithDouble:deltaForPreviousSplit];
}

@end
