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

@property (strong) NSArray *matchedSplits;
@property (readonly, nonatomic) NSNumber *lastMatchedSplitNumber;
@property (nonatomic, strong) SSRunBuilder *runBuilder;
@property (strong) SSRun *referenceRun;

-(SSMatchedSplit *)currentMatchedSplit;
-(SSMatchedSplit *)previousMatchedSplit;

// FIXME: This should be done using KVO:
-(void)_updateMatchedSplits;

// FIXME: These should be NSTimeIntervals.
-(NSNumber *)deltaToStartOfCurrentRoom;

@end
