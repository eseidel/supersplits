//
//  SSAppDelegate.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "SSTimerWindowController.h"
#import "SSDebugWindowController.h"
#import "SSHistoryWindowController.h"
#import "SSCoreDataController.h"

@interface SSAppDelegate : NSObject <NSApplicationDelegate>
{
    SSTimerWindowController *_timerWindowController;
    SSDebugWindowController *_debugWindowController;
    SSHistoryWindowController *_historyWindowController;
    SSMainController *_mainController;
    SSCoreDataController *_coreDataController;

    IBOutlet NSMenuItem *_startStopMenu;
	
	EventHandlerUPP _hotKeyEventHandler;
	
	EventHotKeyRef _startStopHotKeyRef;
	EventHotKeyRef _startStopAlternateHotKeyRef;
	EventHotKeyRef _resetHotKeyRef;
}

- (IBAction)resetRun:(id)sender;
- (IBAction)togglePause:(id)sender;
- (IBAction)showDebugWindow:(id)sender;
- (IBAction)showHistoryWindow:(id)sender;

- (IBAction)saveAsAction:(id)sender;

@end
