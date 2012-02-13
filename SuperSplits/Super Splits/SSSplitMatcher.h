//
//  SSSplitMatcher.h
//  Super Splits
//
//  Created by Eric Seidel on 12/29/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSRun;

@interface SSSplitMatcher : NSObject

// FIXME: This API which allows specifying splits is kinda a hack
// allows us to add a split for the current room.  In reality, this object
// does not want to match splits, but rather some simpler object.
-(NSArray *)matchSplits:(NSArray* )splits fromRun:(SSRun *)run withReferenceRun:(SSRun *)referenceRun;
-(NSArray *)matchSplitsFromRun:(SSRun *)run withReferenceRun:(SSRun *)referenceRun;

- (NSArray *)fillInGaps:(NSArray *)matchedSplits fromReferenceRun:(SSRun *)referenceRun;

@end
