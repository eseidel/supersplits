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

typedef enum {
    UnknownState = 0,
    RoomState,
    RoomTransitionState,
    BlackScreenState,
} SSRunState;

@interface SSRunController : NSObject
{
    NSDate *_overallStart;
    NSDate *_roomStart;
    NSDate *_stateStart;

    NSMutableArray *_roomSplits;
    SSRunState _state;
}

@property (readonly) NSDate *startTime;
@property (readonly) NSArray *roomSplits;
@property (nonatomic) SSRunState state;
@property (readonly) NSString *stateAsString;

-(id)initWithContentsOfURL:(NSURL *)url;

+(NSArray *)runFileTypes;

-(void)writeToURL:(NSURL *)url;
-(void)autosave;

-(SSRoomId)currentRoomId;
-(SSRoomId)lastRoomId;
-(NSNumber *)timeAfterRoom:(SSRoomId)roomId;
-(NSNumber *)splitForRoom:(SSRoomId)roomId;

-(NSNumber *)roomTime;
-(NSNumber *)totalTime;
@end
