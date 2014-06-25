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
{
    NSTimer *_updateTimer;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // FIXME: This should only apply when the emulator is frontmost.
    [self.window setLevel:NSStatusWindowLevel];

    SSTimeIntervalFormatter *intervalFormatter = [[SSTimeIntervalFormatter alloc] init];
    intervalFormatter.hideDeciseconds = YES;
    [[self totalTimeView] setFormatter:intervalFormatter];

    SSTimeDeltaFormatter *deltaFormatter = [[SSTimeDeltaFormatter alloc] init];
    [[self totalTimeDeltaView] setFormatter:deltaFormatter];

    [self updateTimerViews];
}

-(void)startUpdating
{
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 10.0)
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
    [[self totalTimeView] setObjectValue:[runBuilder valueForKey:@"totalTime"]];

    SSRunComparison *comparision = [_mainController runComparison];
    [[self totalTimeDeltaView] setObjectValue:[comparision deltaToStartOfCurrentRoom]];

    // Only show the split for every 5th room in an effort to reduce data overload.
    BOOL showTimeDelta = ([[current roomSplits] count] % 5 == 0) || ![_mainController isRunning];
    [[self totalTimeDeltaView] setHidden:!showTimeDelta];

    SSSplit *currentRoomReference = [comparision valueForKeyPath:@"currentMatchedSplit.referenceSplit"];
    BOOL showRoomName = [_mainController isRunning] && runBuilder.state == RoomState && [[currentRoomReference roomName] length] > 0;
    showRoomName = NO; // Don't show room names until we're more reliable.
    [[self roomNameView] setHidden:!showRoomName];
    [[self timerState] setHidden:showRoomName];
    [[self roomNameView] setObjectValue:[currentRoomReference roomName]];

    // FIXME: This could be done with KVO in IB:
    if (![_mainController isRunning]) {
        [[self timerState] setStringValue:@"paused"];
    } else {
        [[self timerState] setStringValue:[runBuilder stateAsString]];
    }

    if (_mainController.imageSource.speedMultiplier == 1.0)
        [[self speedMultiplierView] setHidden:YES];
    else {
        [[self speedMultiplierView] setHidden:NO];
        NSString *multiplier = [NSString stringWithFormat:@"%dx", (int)_mainController.imageSource.speedMultiplier, nil];
        [[self speedMultiplierView] setStringValue:multiplier];
    }
}

@end
