//
//  SSRun.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSUInteger SSRoomId;
extern const SSRoomId kInvalidRoomId;

@interface SSRunController : NSObject
{
    NSDate *_overallStart;
    NSDate *_roomStart;
    NSDate *_transitionStart;

    NSMutableArray *_roomSplits;
}

@property (readonly) NSDate *startTime;
@property (readonly) NSArray *roomSplits;

-(id)initWithContentsOfURL:(NSURL *)url;

+(NSArray *)runFileTypes;

-(void)writeToURL:(NSURL *)url;

-(void)startRoom;
-(BOOL)inTransition;
-(void)startTransition;
-(void)endTransition;

-(SSRoomId)currentRoomId;
-(SSRoomId)lastRoomId;
-(NSNumber *)timeAfterRoom:(SSRoomId)roomId;
-(NSNumber *)splitForRoom:(SSRoomId)roomId;

-(NSNumber *)roomTime;
-(NSNumber *)totalTime;
@end
