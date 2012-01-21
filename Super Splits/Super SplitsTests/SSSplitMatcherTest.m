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

@implementation SSSplitMatcherTest

- (void)testMatch
{
    SSRun *referenceRun;

    SSSplitMatcher *matcher = [SSSplitMatcher new];
    NSArray *matchedSplits = [matcher matchSplitsFromRun:referenceRun withReferenceRun:referenceRun];

    // FIXME: Check that matchedSplits says that the referenceRun matches itself!
}

@end
