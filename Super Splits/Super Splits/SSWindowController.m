//
//  SSWindowController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSWindowController.h"
#import "SSTimeIntervalFormatter.h"


@implementation SSWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        _mainController = [[SSMainController alloc] init];
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setLevel: NSStatusWindowLevel];

    [totalTimeView setFormatter:[[SSTimeIntervalFormatter alloc] init]];
    [roomTimeView setFormatter:[[SSTimeIntervalFormatter alloc] init]];
    [lastRoomSplitView setFormatter:[[SSTimeIntervalFormatter alloc] init]];

    // FIXME: Eventually we want this to be from a button click, no?
    [_mainController startRun];

    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / 10.0f)
                                              target:self
                                            selector:@selector(timerFired)
                                            userInfo:self
                                             repeats:true];
}

-(NSString *)timeIntervalAsString:(NSTimeInterval)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
    return [dateFormatter stringFromDate:date];
}

-(void)timerFired
{
    [totalTimeView setObjectValue:[_mainController totalTime]];
    [roomTimeView setObjectValue:[_mainController roomTime]];
    [lastRoomSplitView setObjectValue:[_mainController lastRoomSplit]];
}

@end
