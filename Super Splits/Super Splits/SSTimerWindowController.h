//
//  SSTimerWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSMainController;

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
    IBOutlet NSTextField *referenceFractionView;
    IBOutlet NSTextField *splitCountView;
    IBOutlet NSTextField *roomNameView;
}

@property(retain) SSMainController *mainController;

-(void)startUpdating;
-(void)stopUpdating;
-(void)updateTimerViews;

@end
