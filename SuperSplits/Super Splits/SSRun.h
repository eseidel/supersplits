//
//  SSRun.h
//  Super Splits
//
//  Created by Eric Seidel on 12/16/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSEvent;
@class SSSplit;

extern const NSUInteger kInvalidSplitIndex;

// FIXME: Should this subclass from NSDocument?
@interface SSRun : NSObject

@property (readonly, strong) NSMutableArray *roomSplits;
@property (readonly, strong) NSMutableArray *events;
@property (readonly, strong) NSURL *url;
@property (readonly, nonatomic) NSString *filename;

+(NSURL *)defaultURLForRunWithName:(NSString *)name;
+(NSArray *)runFileTypes;

-(SSEvent *)firstEvent;
-(SSEvent *)lastEvent;
-(SSEvent *)lastRoomEvent;
-(SSEvent *)lastMapEvent;
-(SSSplit *)lastSplit;

-(id)initWithContentsOfURL:(NSURL *)url;
-(id)initWithData:(NSData *)data;
-(NSData *)writeToData;
-(void)writeToURL:(NSURL *)url;

-(void)autosave;

-(NSNumber *)timeAfterSplitAtIndex:(NSUInteger)splitIndex;
-(NSUInteger)indexOfFirstSplitAfter:(NSUInteger)splitIndex withEntryMap:(NSString *)mapState scanLimit:(NSUInteger)scanLimit;
-(NSUInteger)indexOfSplitNear:(NSUInteger)startIndex withEntryMap:(NSString *)mapState scanLimit:(NSUInteger)scanLimit;

@end
