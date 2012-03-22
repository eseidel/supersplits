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

@implementation SSTimerWindowController

@synthesize mainController=_mainController;

- (void)windowDidLoad
{
    [super windowDidLoad];

    // FIXME: This should only apply when the emulator is frontmost.
    [self.window setLevel:NSStatusWindowLevel];

    SSTimeIntervalFormatter *intervalFormatter = [[SSTimeIntervalFormatter alloc] init];
    intervalFormatter.hideDeciseconds = YES;
    [totalTimeView setFormatter:intervalFormatter];

    SSTimeDeltaFormatter *deltaFormatter = [[SSTimeDeltaFormatter alloc] init];
    [totalTimeDeltaView setFormatter:deltaFormatter];

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

    SSRunComparison *comparision = [_mainController runComparison];
    [totalTimeDeltaView setObjectValue:[comparision deltaToStartOfCurrentRoom]];

    // Only show the split for every 5th room in an effort to reduce data overload.
    BOOL showTimeDelta = ([[current roomSplits] count] % 5 == 0) || ![_mainController running];
    [totalTimeDeltaView setHidden:!showTimeDelta];

    SSSplit *currentRoomReference = [comparision valueForKeyPath:@"currentMatchedSplit.referenceSplit"];
    BOOL showRoomName = [_mainController running] && runBuilder.state == RoomState && [[currentRoomReference roomName] length] > 0;
    showRoomName = NO; // Don't show room names until we're more reliable.
    [roomNameView setHidden:!showRoomName];
    [timerState setHidden:showRoomName];
    [roomNameView setObjectValue:[currentRoomReference roomName]];

    // FIXME: This could be done with KVO in IB:
    if (![_mainController running]) {
        [timerState setStringValue:@"paused"];
    } else {
        [timerState setStringValue:[runBuilder stateAsString]];
    }

    if (_mainController.imageSource.speedMultiplier == 1.0)
        [speedMultiplierView setHidden:YES];
    else {
        [speedMultiplierView setHidden:NO];
        NSString *multiplier = [NSString stringWithFormat:@"%dx", (int)_mainController.imageSource.speedMultiplier, nil];
        [speedMultiplierView setStringValue:multiplier];
    }
}

@end
