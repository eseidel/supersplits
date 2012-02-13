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
@property NSUInteger splitIndex; // 0-based.
@property (readonly) NSNumber *splitNumber; // 1-based.

@property (retain) SSSplit *referenceSplit;
@property NSUInteger referenceSplitIndex; // 0-based.
@property (readonly) NSNumber *referenceSplitNumber; // 1-based.

@property (readonly) NSNumber *durationDifference;

@end
