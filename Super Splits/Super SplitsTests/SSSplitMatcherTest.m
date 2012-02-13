//
//  SSSplitMatcherTest.m
//  Super Splits
//
//  Created by Adam Barth on 1/21/12.
//  Copyright (c) 2012 Eric Seidel. All rights reserved.
//

#import "SSSplitMatcherTest.h"

#import "SSRun.h"
#import "SSSplitMatcher.h"
#import "SSMatchedSplit.h"
#import "SSSplit.h"
#import "SSRunBuilder.h"
#import "SSRunComparison.h"

@implementation SSSplitMatcherTest

- (SSRun *)_loadRun:(NSString *)runName
{
    // mainBundle doesn't work for OCUnit: http://stackoverflow.com/questions/3067015/ocunit-nsbundle
    NSBundle *unittestBundle = [NSBundle bundleForClass:[self class]];
    NSURL *runURL =[unittestBundle URLForResource:runName withExtension:@"txt"];
    return [[SSRun alloc] initWithContentsOfURL:runURL];
}

- (void)testFullSelfMatch
{
    SSRun *run = [self _loadRun:@"6Jan2012"];

    SSSplitMatcher *matcher = [SSSplitMatcher new];
    NSArray *matchedSplits = [matcher matchSplitsFromRun:run withReferenceRun:run];
    NSUInteger splitCount = run.roomSplits.count;
    STAssertEquals(matchedSplits.count, splitCount, @"matcher split count");
    for (NSUInteger splitIndex = 0; splitIndex < splitCount; splitIndex++) {
        SSMatchedSplit *matchedSplit = [matchedSplits objectAtIndex:splitIndex];
        STAssertEquals(matchedSplit.splitIndex, splitIndex, @"splitIndex should match");
        STAssertEquals(matchedSplit.referenceSplitIndex, splitIndex, @"referenceSplitIndex should match");

        SSSplit *split = [run.roomSplits objectAtIndex:splitIndex];
        STAssertEquals(matchedSplit.split, split, @"split should match");
        STAssertEquals(matchedSplit.referenceSplit, split, @"referenceSplit should match");
    }
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

- (void)testIncrementalSelfMatch
{
    SSRun *run = [self _loadRun:@"6Jan2012"];
    NSArray *matchedSplits = [self _matchedSplitsFromIncrementalMatchOfRun:run withRefernce:run];

    NSUInteger splitCount = run.roomSplits.count;
    STAssertEquals(matchedSplits.count, splitCount, @"matcher split count");
    for (NSUInteger splitIndex = 0; splitIndex < splitCount; splitIndex++) {
        SSMatchedSplit *matchedSplit = [matchedSplits objectAtIndex:splitIndex];
        STAssertEquals(matchedSplit.splitIndex, splitIndex, @"splitIndex should match");
        STAssertEquals(matchedSplit.referenceSplitIndex, splitIndex, @"referenceSplitIndex should match");

        SSSplit *split = [run.roomSplits objectAtIndex:splitIndex];
        STAssertEquals(matchedSplit.referenceSplit, split, @"referenceSplit should match");
        STAssertEqualObjects(matchedSplit.split.entryMapState, split.entryMapState, @"entryMapState should match");
        STAssertEquals((int)matchedSplit.split.duration, (int)split.duration, @"duration should match");    
    }
}

- (void)testIncrementalMatch
{
    SSRun *run = [self _loadRun:@"6Jan2012"];
    SSRun *referenceRun = [self _loadRun:@"6Jan2012-reference"];
    NSArray *matchedSplits = [self _matchedSplitsFromIncrementalMatchOfRun:run withRefernce:referenceRun];

    NSUInteger splitCount = run.roomSplits.count;
    STAssertEquals(matchedSplits.count, splitCount, @"matcher split count");
    for (NSUInteger splitIndex = 0; splitIndex < splitCount; splitIndex++) {
        SSMatchedSplit *matchedSplit = [matchedSplits objectAtIndex:splitIndex];
        STAssertEquals(matchedSplit.splitIndex, splitIndex, @"splitIndex should match");
        STAssertEquals(matchedSplit.referenceSplitIndex, splitIndex, @"referenceSplitIndex should match");
        
        SSSplit *split = [run.roomSplits objectAtIndex:splitIndex];
        STAssertEqualObjects(matchedSplit.split.entryMapState, split.entryMapState, @"entryMapState should match");
        STAssertEquals((int)matchedSplit.split.duration, (int)split.duration, @"duration should match");    
    }
}

@end
