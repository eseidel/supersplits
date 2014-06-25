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

- (id)init
{
    self = [super init];
    if (self) {
        _splitIndex = kInvalidSplitIndex;
        _referenceSplitIndex = kInvalidSplitIndex;
    }
    return self;
}

- (NSNumber *)durationDifference
{
    if (!_split || !_referenceSplit)
        return nil;
    return @([_split duration] - [_referenceSplit duration]);
}

- (NSNumber *)splitNumber
{
    if (_splitIndex == kInvalidSplitIndex)
        return nil;
    return @(_splitIndex + 1);
}

- (NSNumber *)referenceSplitNumber
{
    if (_referenceSplitIndex == kInvalidSplitIndex)
        return nil;
    return @(_referenceSplitIndex + 1);
}

@end
