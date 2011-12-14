//
//  SSTimerWindowController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSTimerWindowController.h"

#import "SSMainController.h"
#import "SSRunController.h"
#import "SSSplit.h"
#import "SSTimeDeltaFormatter.h"
#import "SSTimeIntervalFormatter.h"

@implementation SSTimerWindowController

@synthesize mainController=_mainController;

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setLevel:NSStatusWindowLevel];

    SSTimeIntervalFormatter *intervalFormatter = [[SSTimeIntervalFormatter alloc] init];
    [totalTimeView setFormatter:intervalFormatter];
    [roomTimeView setFormatter:intervalFormatter];
    [lastRoomSplitView setFormatter:intervalFormatter];
    [roomReferenceTimeView setFormatter:intervalFormatter];

    SSTimeDeltaFormatter *deltaFormatter = [[SSTimeDeltaFormatter alloc] init];
    [totalTimeDeltaView setFormatter:deltaFormatter];
    [lastRoomSplitDeltaView setFormatter:deltaFormatter];

    [self updateTimerViews];
}

-(void)startUpdating
{
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / 10.0f)
                                                    target:self
                                                  selector:@selector(updateTimerViews)
                                                  userInfo:self
                                                   repeats:true];
}

-(void)stopUpdating
{
    [_updateTimer invalidate];
    [self updateTimerViews]; // Do one last update.
}

-(void)updateTimerViews
{
    SSRunController *current = [_mainController currentRun];
    SSRunController *reference = [_mainController referenceRun];

    [totalTimeView setObjectValue:[current totalTime]];
    [roomTimeView setObjectValue:[current roomTime]];
    SSSplit *lastSplit = [[current roomSplits] lastObject];
    [lastRoomSplitView setObjectValue:[lastSplit duration]];

    [roomReferenceTimeView setObjectValue:[reference splitForRoom:[current currentRoomId]]];

    SSRoomId lastRoomId = [current lastRoomId];
    NSNumber *referenceSplit = [reference splitForRoom:lastRoomId];
    if (referenceSplit) {
        NSTimeInterval deltaAfterLastRoom = [[current timeAfterRoom:lastRoomId] doubleValue]
                                          - [[reference timeAfterRoom:lastRoomId] doubleValue];
        [totalTimeDeltaView setObjectValue:[NSNumber numberWithDouble:deltaAfterLastRoom]];

        NSTimeInterval splitDelta = [[current splitForRoom:lastRoomId] doubleValue]
                                  - [referenceSplit doubleValue];
        [lastRoomSplitDeltaView setObjectValue:[NSNumber numberWithDouble:splitDelta]];
    } else {
        [totalTimeDeltaView setObjectValue:nil];
        [lastRoomSplitDeltaView setObjectValue:nil];
    }
    
    if (!_mainController.running) {
        [timerState setStringValue:@"paused"];
    } else {
        [timerState setStringValue:[current stateAsString]];
    }
}

@end
