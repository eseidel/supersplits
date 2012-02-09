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

@implementation SSSplitMatcherTest

- (SSRun *)_loadRun:(NSString *)runName
{
    // mainBundle doesn't work for OCUnit: http://stackoverflow.com/questions/3067015/ocunit-nsbundle
    NSBundle *unittestBundle = [NSBundle bundleForClass:[self class]];
    NSURL *runURL =[unittestBundle URLForResource:runName withExtension:@"txt"];
    return [[SSRun alloc] initWithContentsOfURL:runURL];
}

- (void)testMatch
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

@end
