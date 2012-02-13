//
//  SSTestMain.m
//  Super Splits
//
//  Created by Eric Seidel on 2/12/12.
//  Copyright (c) 2012 Eric Seidel. All rights reserved.
//

#import "SSTestMain.h"

#import "SSRun.h"
#import "SSSplitMatcher.h"
#import "SSSplit.h"
#import "SSMatchedSplit.h"
#import "SSRunComparison.h"
#import "SSRunBuilder.h"

@implementation SSTestMain

- (SSRun *)_loadRun:(NSString *)path
{
    SSRun * run = [[SSRun alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    if (!run) {
        NSLog(@"Failed to load run: %@", path);
    }
    return run;
}

- (NSArray *)_matchedSplitsFromIncrementalMatchOfRun:(SSRun *)run withRefernce:(SSRun *)referenceRun
{
    SSRunComparison *comparison = [SSRunComparison new];
    SSRunBuilder *runBuilder = [SSRunBuilder new];
    comparison.runBuilder = runBuilder;
    comparison.referenceRun = referenceRun;
    
    // Pretend we got the map information .5s after entering the room (common).
    const float kEntryMapStateOffset = 0.5;
    
    // We walk through the run, telling the comparison object about each new room
    NSUInteger splitCount = run.roomSplits.count;
    for (NSUInteger splitIndex = 0; splitIndex < splitCount; splitIndex++) {
        SSSplit *split = [run.roomSplits objectAtIndex:splitIndex];
        
        // Pretend we spent 1.5 seconds in the previous door/cutscene, but now enter a room.
        runBuilder.offset += 1.5;
        runBuilder.state = RoomState;
        [comparison _updateMatchedSplits];
        
        // Update the map state after an offset.
        runBuilder.offset += kEntryMapStateOffset;
        runBuilder.state = RoomState;
        [runBuilder _updateMinimapState:split.entryMapState];
        [comparison _updateMatchedSplits];
        
        // Record that we spent "duration" in this room, and then transition into a Door state.
        runBuilder.offset += split.duration - kEntryMapStateOffset;
        runBuilder.state = RoomTransitionState;
        [comparison _updateMatchedSplits];
    }
    return comparison.matchedSplits;
}

- (int)runWithArgs:(NSArray *)args
{
    if (args.count < 2) {
        NSLog(@"Usage: TestHarness <reference> <run>");
        return 1;
    }

    SSRun *reference = [self _loadRun:[args objectAtIndex:0]];
    SSRun *run = [self _loadRun:[args objectAtIndex:1]];

    SSSplitMatcher *matcher = [SSSplitMatcher new];
    NSArray *matchedSplits = [matcher matchSplitsFromRun:run withReferenceRun:reference];
//    NSArray *matchedSplits = [self _matchedSplitsFromIncrementalMatchOfRun:run withRefernce:reference];
    NSUInteger splitCount = run.roomSplits.count;
    for (NSUInteger splitIndex = 0; splitIndex < splitCount; splitIndex++) {
        SSMatchedSplit *matchedSplit = [matchedSplits objectAtIndex:splitIndex];
        if (matchedSplit.referenceSplitIndex == kInvalidSplitIndex)
            printf("none\n");
        else
            printf("%lu\n", matchedSplit.referenceSplitIndex);
    }
    return 0;
}

@end
