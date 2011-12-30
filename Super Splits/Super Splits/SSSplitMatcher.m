//
//  SSSplitMatcher.m
//  Super Splits
//
//  Created by Eric Seidel on 12/29/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSSplitMatcher.h"
#import "SSRun.h"
#import "SSMatchedSplit.h"

@implementation SSSplitMatcher

-(NSArray *)matchSplitsFromRun:(SSRun *)run withReferenceRun:(SSRun *)referenceRun
{
    NSInteger splitIndex = 0;
    NSArray *splits = [run roomSplits];
    NSInteger splitCount = [splits count];

    NSInteger referenceSplitIndex = 0;
    NSArray *referenceSplits = [referenceRun roomSplits];
    NSInteger referenceSplitCount = [referenceSplits count];

    NSMutableArray *matchedSplits = [NSMutableArray array];

    while (splitIndex < splitCount || referenceSplitIndex < referenceSplitCount) {
        SSMatchedSplit *matchedSplit = [[SSMatchedSplit alloc] init];

        if (splitIndex < splitCount)
            matchedSplit.split = [splits objectAtIndex:splitIndex];
        if (referenceSplitIndex < referenceSplitCount)
            matchedSplit.referenceSplit = [referenceSplits objectAtIndex:referenceSplitIndex];
        
        [matchedSplits addObject: matchedSplit];

        splitIndex++;
        referenceSplitIndex++;
    }
    return matchedSplits;
}

@end
