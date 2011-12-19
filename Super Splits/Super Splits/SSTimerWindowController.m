//
//  SSTimerWindowController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSTimerWindowController.h"

#import "SSMainController.h"
#import "SSRun.h"
#import "SSRunBuilder.h"
#import "SSRunComparison.h"
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
    SSRunBuilder *runBuilder = [_mainController runBuilder];
    SSRun *current = [runBuilder run];

    [totalTimeView setObjectValue:[runBuilder totalTime]];
    [roomTimeView setObjectValue:[runBuilder roomTime]];
    SSSplit *lastSplit = [[current roomSplits] lastObject];
    [lastRoomSplitView setObjectValue:[lastSplit duration]];

    SSRunComparison *comparision = [_mainController runComparison];
    SSSplit *currentRoomReference = [comparision currentSplitReference];
    [roomReferenceTimeView setObjectValue:[currentRoomReference duration]];
    [totalTimeDeltaView setObjectValue:[comparision deltaToStartOfCurrentRoom]];
    [lastRoomSplitDeltaView setObjectValue:[comparision deltaForPreviousSplit]];

    NSNumber *lastMatchedSplitNumber = [comparision lastMatchedSplitNumber];
    SSRun *reference = [_mainController referenceRun];
    NSString *referenceFractionString = [NSString stringWithFormat:@"%@ / %lu", lastMatchedSplitNumber, [[reference roomSplits] count]];
    [referenceFractionView setStringValue:referenceFractionString];
    [splitCountView setIntegerValue:[[current roomSplits] count] + 1];

    if (![_mainController running]) {
        [timerState setStringValue:@"paused"];
    } else {
        [timerState setStringValue:[runBuilder stateAsString]];
    }
}

@end
