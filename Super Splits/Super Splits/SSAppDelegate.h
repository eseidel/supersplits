//
//  SSAppDelegate.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "SSWindowController.h"

@interface SSAppDelegate : NSObject <NSApplicationDelegate>
{
    SSWindowController *_windowController;
    SSMainController *_mainController;

    IBOutlet NSMenuItem *_startStopMenu;
	
	EventHandlerUPP _hotKeyEventHandler;
	
	EventHotKeyRef _startStopHotKeyRef;
	EventHotKeyRef _startStopAlternateHotKeyRef;
	EventHotKeyRef _resetHotKeyRef;
}

- (IBAction)resetRun:(id)sender;
- (IBAction)togglePause:(id)sender;

@end
