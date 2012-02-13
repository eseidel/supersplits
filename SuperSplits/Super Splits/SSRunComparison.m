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
#import "SSSplitMatcher.h"
#import "SSMatchedSplit.h"
#import "SSSplit.h"

@implementation SSRunComparison

@synthesize runBuilder=_runBuilder, referenceRun=_referenceRun, matchedSplits=_matchedSplits;

-(id)init
{
    if (self = [super init]) {
        _splitMatcher = [[SSSplitMatcher alloc] init];
    }
    return self;
}

-(void)_updateMatchedSplits
{
    NSMutableArray *splits = [_runBuilder.run.roomSplits mutableCopy];
    if (_runBuilder.currentSplit)
        [splits addObject:_runBuilder.currentSplit];
    self.matchedSplits = [_splitMatcher matchSplits:splits
                                            fromRun:_runBuilder.run
                                   withReferenceRun:_referenceRun];
}

-(NSNumber *)lastMatchedSplitNumber
{
    for (SSMatchedSplit *matchedSplit in [_matchedSplits reverseObjectEnumerator]) {
        if (matchedSplit.referenceSplit)
            return matchedSplit.splitNumber;
    }
    return nil;
}

-(SSMatchedSplit *)currentMatchedSplit
{
    return [_matchedSplits lastObject];
}

-(SSMatchedSplit *)previousMatchedSplit
{
    if (_matchedSplits.count > 1)
        return [_matchedSplits objectAtIndex:(_matchedSplits.count - 2)];
    return nil;
}

-(NSNumber *)deltaToStartOfCurrentRoom
{
    NSNumber *referenceTimeAfterLastRoom = nil;
    if (self.previousMatchedSplit.referenceSplitIndex != kInvalidSplitIndex)
        referenceTimeAfterLastRoom = [_referenceRun timeAfterSplitAtIndex:self.previousMatchedSplit.referenceSplitIndex];
    else if (self.currentMatchedSplit.referenceSplitIndex != kInvalidSplitIndex) {
        // If we don't have a previous split (the last room was confused)
        // but we do know what this room is, then we compute the time
        // up until this room from the reference.
        // FIXME: This probably isn't needed now that we're using a SSSplitMatcher.
        referenceTimeAfterLastRoom = [_referenceRun timeAfterSplitAtIndex:self.currentMatchedSplit.referenceSplitIndex - 1];
    } else
        return nil;

    NSNumber *timeAfterLastRoom = [[_runBuilder run] timeAfterSplitAtIndex:self.previousMatchedSplit.splitIndex];
    NSTimeInterval deltaAfterLastRoom = [timeAfterLastRoom doubleValue] - [referenceTimeAfterLastRoom doubleValue];
    return [NSNumber numberWithDouble:deltaAfterLastRoom];
}

@end
