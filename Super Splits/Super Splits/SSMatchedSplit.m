//
//  SSMatchedSplit.m
//  Super Splits
//
//  Created by Eric Seidel on 12/29/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMatchedSplit.h"
#import "SSSplit.h"
#import "SSRun.h"

@implementation SSMatchedSplit

@synthesize split=_split, splitIndex=_splitIndex, referenceSplit=_referenceSplit, referenceSplitIndex=_referenceSplitIndex;

- (id)init
{
    if (self = [super init]) {
        _splitIndex = kInvalidSplitIndex;
        _referenceSplitIndex = kInvalidSplitIndex;
    }
    return self;
}

- (NSNumber *)durationDifference
{
    if (!_split || !_referenceSplit)
        return nil;
    return [NSNumber numberWithDouble:[_split duration] - [_referenceSplit duration]];
}

- (NSNumber *)splitIndexNumber
{
    if (_splitIndex == kInvalidSplitIndex)
        return nil;
    return [NSNumber numberWithUnsignedInteger:_splitIndex];
}

- (NSNumber *)referenceSplitIndexNumber
{
    if (_referenceSplitIndex == kInvalidSplitIndex)
        return nil;
    return [NSNumber numberWithUnsignedInteger:_referenceSplitIndex];
}

@end
