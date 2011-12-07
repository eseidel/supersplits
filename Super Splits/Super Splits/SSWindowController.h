//
//  SSWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSMainController.h"

@interface SSWindowController : NSWindowController
{
    SSMainController *_mainController;

    NSTimer *_updateTimer;

    IBOutlet NSTextField *totalTimeView;
    IBOutlet NSTextField *roomTimeView;
    IBOutlet NSTextField *lastRoomSplitView;
}

@property(retain) SSMainController *mainController;

-(void)startUpdating;
-(void)stopUpdating;
-(void)updateTimerViews;

@end
