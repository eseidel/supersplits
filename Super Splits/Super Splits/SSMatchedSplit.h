//
//  SSMatchedSplit.h
//  Super Splits
//
//  Created by Eric Seidel on 12/29/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSSplit;

@interface SSMatchedSplit : NSObject

@property (retain) SSSplit *split;
@property NSUInteger splitIndex;
@property (readonly) NSNumber *splitIndexNumber;

@property (retain) SSSplit *referenceSplit;
@property NSUInteger referenceSplitIndex;
@property (readonly) NSNumber *referenceSplitIndexNumber;

@property (readonly) NSNumber *durationDifference;

@end
