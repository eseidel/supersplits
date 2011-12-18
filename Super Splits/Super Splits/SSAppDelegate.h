//
//  SSAppDelegate.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class SSTimerWindowController;
@class SSDebugWindowController;
@class SSHistoryWindowController;
@class SSMainController;
@class SSCoreDataController;

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

- (IBAction)saveAs:(id)sender;
- (IBAction)saveAsReference:(id)sender;
- (IBAction)loadReferenceRun:(id)sender;

@end
