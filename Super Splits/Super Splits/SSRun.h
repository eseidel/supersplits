//
//  SSRun.h
//  Super Splits
//
//  Created by Eric Seidel on 12/16/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger kInvalidSplitIndex;

@interface SSRun : NSObject

@property (readonly, retain) NSMutableArray *roomSplits;
@property (readonly, retain) NSMutableArray *events;

-(id)initWithContentsOfURL:(NSURL *)url;
-(void)writeToURL:(NSURL *)url;

-(NSNumber *)timeAfterSplitAtIndex:(NSUInteger)splitIndex;
-(NSUInteger)indexOfFirstSplitAfter:(NSUInteger)splitIndex withEntryMap:(NSString *)mapState scanLimit:(NSUInteger)scanLimit;

@end
