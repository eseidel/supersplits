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
#import "SSWindowImageSource.h"
#import "SSEvent.h"

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

    // FIXME: This should all be done with KVO, once SSRunBuilder is KVO compliant.
    [totalTimeView setObjectValue:[runBuilder valueForKey:@"totalTime"]];
    [roomTimeView setObjectValue:[runBuilder valueForKey:@"roomTime"]];
    [lastRoomSplitView setObjectValue:[[current lastSplit] valueForKey:@"duration"]];

    SSRunComparison *comparision = [_mainController runComparison];
    SSSplit *currentRoomReference = [comparision valueForKeyPath:@"currentMatchedSplit.referenceSplit"];
    [roomReferenceTimeView setObjectValue:[currentRoomReference valueForKey:@"duration"]];
    [totalTimeDeltaView setObjectValue:[comparision deltaToStartOfCurrentRoom]];
    [lastRoomSplitDeltaView setObjectValue:[comparision valueForKeyPath:@"previousMatchedSplit.durationDifference"]];

    SSEvent *lastEvent = [current lastEvent];
    BOOL showRoomName = [_mainController running] && lastEvent.type == RoomEvent && [[currentRoomReference roomName] length] > 0; 
    [roomNameView setHidden:!showRoomName];
    [timerState setHidden:showRoomName];
    [roomNameView setObjectValue:[currentRoomReference roomName]];

    // FIXME: This could be done with KVO in IB:
    if (![_mainController running])
        [timerState setStringValue:@"paused"];
    else if (!lastEvent)
        [timerState setStringValue:@"ready"];
    else
        [timerState setStringValue:[lastEvent typeName]];

    NSNumber *lastMatchedSplitNumber = [comparision lastMatchedSplitNumber];
    SSRun *reference = [_mainController referenceRun];
    NSString *referenceFractionString = [NSString stringWithFormat:@"%@ / %lu", lastMatchedSplitNumber, [[reference roomSplits] count]];
    [referenceFractionView setStringValue:referenceFractionString];
    [splitCountView setIntegerValue:[[current roomSplits] count] + 1];

    if (_mainController.imageSource.speedMultiplier == 1.0)
        [speedMultiplierView setHidden:YES];
    else {
        [speedMultiplierView setHidden:NO];
        NSString *multiplier = [NSString stringWithFormat:@"%dx", (int)_mainController.imageSource.speedMultiplier, nil];
        [speedMultiplierView setStringValue:multiplier];
    }
}

@end
