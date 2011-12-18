//
//  SSRunController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSRun;

typedef enum {
    UnknownState = 0,
    RoomState,
    RoomTransitionState,
    BlackScreenState,
    ItemScreenState,
} SSRunState;

@interface SSRunController : NSObject
{
    SSRun *_run;

    NSTimeInterval _offset;
    NSTimeInterval _startOffset;

    NSTimeInterval _roomStart;
    NSTimeInterval _stateStart;
    NSString *_roomEntryMapState;

    SSRunState _state;
    NSString *_mapState;
}

@property (readonly) SSRun *currentRun;

@property NSTimeInterval offset;

@property (nonatomic) SSRunState state;
@property (readonly) NSString *stateAsString;

@property (retain, nonatomic) NSString *mapState;
@property (readonly) NSString *roomEntryMapState;

-(NSNumber *)roomTime;
-(NSNumber *)totalTime;


@end
