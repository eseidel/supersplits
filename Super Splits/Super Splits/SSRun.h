//
//  SSRun.h
//  Super Splits
//
//  Created by Eric Seidel on 12/16/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger kInvalidSplitIndex;

// FIXME: Should this subclass from NSDocument?
@interface SSRun : NSObject
{
    NSDate *_startDate;
}

@property (readonly, retain) NSMutableArray *roomSplits;
@property (readonly, retain) NSMutableArray *events;
@property (readonly, retain) NSURL *url;
@property (readonly) NSString *filename;

+(NSArray *)runFileTypes;

-(id)initWithContentsOfURL:(NSURL *)url;
-(void)writeToURL:(NSURL *)url;

-(void)autosave;

-(NSNumber *)timeAfterSplitAtIndex:(NSUInteger)splitIndex;
-(NSUInteger)indexOfFirstSplitAfter:(NSUInteger)splitIndex withEntryMap:(NSString *)mapState scanLimit:(NSUInteger)scanLimit;

@end
