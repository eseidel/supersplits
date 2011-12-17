//
//  SSRun.h
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
    NSDate *_overallStart;
    NSDate *_roomStart;
    NSDate *_stateStart;
    NSString *_roomEntryMapState;

    SSRunState _state;
    NSString *_mapState;
    double _speedMultiplier;
}

@property (readonly) SSRun *currentRun;
@property (readonly) NSDate *startTime;
@property (nonatomic) SSRunState state;
@property (readonly) NSString *stateAsString;
@property (nonatomic) double speedMultiplier;
@property (retain, nonatomic) NSString *mapState;
@property (readonly) NSString *roomEntryMapState;

+(NSArray *)runFileTypes;

-(void)autosave;

-(NSNumber *)roomTime;
-(NSNumber *)totalTime;


@end
