//
//  SSMatchedSplit.m
//  Super Splits
//
//  Created by Eric Seidel on 12/29/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMatchedSplit.h"
#import "SSSplit.h"

@implementation SSMatchedSplit

@synthesize split=_split, referenceSplit=_referenceSplit;

- (NSNumber *)durationDifference
{
    if (!_split || !_referenceSplit)
        return nil;
    return [NSNumber numberWithDouble:[_split duration] - [_referenceSplit duration]];
}

@end
