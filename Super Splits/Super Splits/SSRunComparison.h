//
//  SSRunComparison.h
//  Super Splits
//
//  Created by Eric Seidel on 12/19/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSSplit;
@class SSSplitMatcher;
@class SSMatchedSplit;
@class SSRun;
@class SSRunBuilder;

// FIXME: This is not a particularly good design, but this logic makes
// sense on its own object, even if not one that looks exactly like this.
@interface SSRunComparison : NSObject
{
    SSSplitMatcher *_splitMatcher;
}

@property (retain) NSArray *matchedSplits;
@property (readonly) NSNumber *lastMatchedSplitNumber;
@property (nonatomic, retain) SSRunBuilder *runBuilder;
@property (retain) SSRun *referenceRun;

-(SSMatchedSplit *)currentMatchedSplit;
-(SSMatchedSplit *)previousMatchedSplit;

// FIXME: This should be done using KVO:
-(void)_updateMatchedSplits;

// FIXME: These should be NSTimeIntervals.
-(NSNumber *)deltaToStartOfCurrentRoom;

@end
