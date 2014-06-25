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

@property (strong) SSSplit *split;
@property NSUInteger splitIndex; // 0-based.
@property (readonly, nonatomic) NSNumber *splitNumber; // 1-based.

@property (strong) SSSplit *referenceSplit;
@property NSUInteger referenceSplitIndex; // 0-based.
@property (readonly, nonatomic) NSNumber *referenceSplitNumber; // 1-based.

@property (readonly, nonatomic) NSNumber *durationDifference;

@end
