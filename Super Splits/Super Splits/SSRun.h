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

typedef enum {
    UnknownState = 0,
    RoomState,
    RoomTransitionState,
    BlackScreenState,
    ItemScreenState,
} SSRunState;

// FIXME: Should this subclass from NSDocument?
@interface SSRun : NSObject
{
    NSDate *_startDate;
}

@property (readonly, retain) NSMutableArray *roomSplits;
@property (readonly, retain) NSMutableArray *events;
@property (readonly, retain) NSURL *url;
@property (readonly) NSString *filename;

+(NSURL *)defaultURLForRunWithName:(NSString *)name;
+(NSArray *)runFileTypes;

@property SSRunState state;

-(NSString *)stringForState:(SSRunState)state;

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
