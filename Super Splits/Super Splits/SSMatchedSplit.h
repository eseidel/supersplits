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
@property (retain) SSSplit *referenceSplit;

@property (readonly) NSNumber *durationDifference;

@end
