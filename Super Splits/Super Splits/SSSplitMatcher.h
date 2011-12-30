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

-(NSArray *)matchSplitsFromRun:(SSRun *)run withReferenceRun:(SSRun *)referenceRun;

@end
