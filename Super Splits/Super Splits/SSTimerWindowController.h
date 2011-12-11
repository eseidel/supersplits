//
//  SSWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSMainController.h"

@interface SSTimerWindowController : NSWindowController
{
    SSMainController *_mainController;

    NSTimer *_updateTimer;

    IBOutlet NSTextField *totalTimeView;
    IBOutlet NSTextField *totalTimeDeltaView;
    IBOutlet NSTextField *roomTimeView;
    IBOutlet NSTextField *roomReferenceTimeView;
    IBOutlet NSTextField *lastRoomSplitView;
    IBOutlet NSTextField *lastRoomSplitDeltaView;
    IBOutlet NSTextField *timerState;
}

@property(retain) SSMainController *mainController;

-(void)startUpdating;
-(void)stopUpdating;
-(void)updateTimerViews;

@end
