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

@implementation SSTestMain

- (SSRun *)_loadRun:(NSString *)path
{
    return [[SSRun alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
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
    NSUInteger splitCount = run.roomSplits.count;
    for (NSUInteger splitIndex = 0; splitIndex < splitCount; splitIndex++) {
        SSMatchedSplit *matchedSplit = [matchedSplits objectAtIndex:splitIndex];
//        SSSplit *split = [run.roomSplits objectAtIndex:splitIndex];
        NSLog(@"foo: %@", matchedSplit);
    }
    return 0;
}

@end
