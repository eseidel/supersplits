//
//  SSRunComparison.h
//  Super Splits
//
//  Created by Eric Seidel on 12/19/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSSplit;
@class SSRun;
@class SSRunBuilder;

// FIXME: This is not a particularly good design, but this logic makes
// sense on its own object, even if not one that looks exactly like this.
@interface SSRunComparison : NSObject
{
    NSUInteger _currentReferenceSplitIndex; // Reference for current room.
    NSUInteger _previousReferenceSplitIndex; // Reference for the previous room.
    NSUInteger _lastMatchedReferenceSplitIndex; // Last room we successfully matched a reference for.
    NSUInteger _lastMatchedSplitIndex;
    NSUInteger _lastSearchedSplitIndex;
}

@property (readonly) NSNumber *lastMatchedSplitNumber;
@property (retain) SSRunBuilder *runBuilder;
@property (retain) SSRun *referenceRun;

-(SSSplit *)currentSplitReference;
-(SSSplit *)previousSplitReference;

// FIXME: These should be NSTimeIntervals.
-(NSNumber *)deltaToStartOfCurrentRoom;
-(NSNumber *)deltaForPreviousSplit;

// FIXME: These explicit calls could be replaced by KVO calls on "run".
-(void)roomChanged;
-(void)updateReferenceCursors;
-(BOOL)haveSearchedForCurrentSplit;

@end
