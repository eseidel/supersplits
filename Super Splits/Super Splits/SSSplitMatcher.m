//
//  SSSplitMatcher.m
//  Super Splits
//
//  Created by Eric Seidel on 12/29/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSSplitMatcher.h"
#import "SSRun.h"
#import "SSSplit.h"
#import "SSMatchedSplit.h"

@implementation SSSplitMatcher

-(SSMatchedSplit *)_matchSplitAtIndex:(NSUInteger)splitIndex
                                inRun:(SSRun *)run
                  againstReferenceRun:(SSRun *)referenceRun
                     lastMatchedSplit:(SSMatchedSplit *)lastMatchedSplit
{
    SSSplit *split = [[run roomSplits] objectAtIndex:splitIndex];
    NSUInteger referenceSplitIndex = kInvalidSplitIndex;
    // Look for a split where we would expect one, given the last known offset.
    if (lastMatchedSplit && lastMatchedSplit.referenceSplitIndex != kInvalidSplitIndex) {
        // Start our search at the offset we would anticipate this current
        // room to be, assuming no backtracking.
        NSInteger splitsSinceLastMatch = splitIndex - lastMatchedSplit.splitIndex;
        assert(splitsSinceLastMatch > 0);
        NSUInteger startIndex = lastMatchedSplit.referenceSplitIndex + splitsSinceLastMatch;
        referenceSplitIndex = [referenceRun indexOfSplitNear:startIndex
                                              withEntryMap:split.entryMapState
                                                 scanLimit:3];
    }
    
    // If that failed, look for a reference split near the current room index.
    // This corrects for times when we're really confused, but our run
    // isn't that different from the reference run.
    // We might consider only using this search once we've failed to find a room for N rooms.
    if (referenceSplitIndex == kInvalidSplitIndex) {
        // FIXME: We should adjust from [self _currentSplitIndex] for times when we know we backtracked?
        // Note: This will fail to find a room if we backtracked more than 3 times.
        // FIXME: We should search wider as we get more confused.
        referenceSplitIndex = [referenceRun indexOfSplitNear:splitIndex
                                                withEntryMap:split.entryMapState
                                                   scanLimit:6];
    }

    SSMatchedSplit *matchedSplit = [[SSMatchedSplit alloc] init];
    matchedSplit.splitIndex = splitIndex;
    matchedSplit.split = split;
    if (referenceSplitIndex != kInvalidSplitIndex) {
        matchedSplit.referenceSplitIndex = referenceSplitIndex;
        matchedSplit.referenceSplit = [[referenceRun roomSplits] objectAtIndex:referenceSplitIndex];
    }
    return matchedSplit;
}

-(NSArray *)matchSplitsFromRun:(SSRun *)run withReferenceRun:(SSRun *)referenceRun
{
    NSInteger splitIndex = 0;
    NSArray *splits = [run roomSplits];
    NSInteger splitCount = [splits count];

    NSMutableArray *matchedSplits = [NSMutableArray array];
    while (splitIndex < splitCount) {
        SSMatchedSplit *matchedSplit = [self _matchSplitAtIndex:splitIndex
                                                          inRun:run
                                            againstReferenceRun:referenceRun
                                               lastMatchedSplit:[matchedSplits lastObject]];
        [matchedSplits addObject: matchedSplit];
        splitIndex++;
    }
    return matchedSplits;
}

@end
