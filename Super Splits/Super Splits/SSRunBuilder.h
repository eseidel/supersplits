//
//  SSRunBuilder.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSMetroidFrame;
@class SSRun;

typedef enum {
    UnknownState = 0,
    RoomState,
    RoomTransitionState,
    BlackScreenState,
    ItemScreenState,
} SSRunState;

@interface SSRunBuilder : NSObject
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

@property (readonly) SSRun *run;

@property NSTimeInterval offset;

@property (nonatomic) SSRunState state;
@property (readonly) NSString *stateAsString;

@property (retain, nonatomic) NSString *mapState;
@property (readonly) NSString *roomEntryMapState;

-(NSNumber *)roomTime;
-(NSNumber *)totalTime;

-(void)updateWithFrame:(SSMetroidFrame *)frame atOffset:(NSTimeInterval)offset;

@end
