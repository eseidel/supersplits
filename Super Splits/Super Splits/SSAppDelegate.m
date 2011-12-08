//
//  SSAppDelegate.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSAppDelegate.h"

#define START_STOP_HOT_KEY_ID 'stss'
#define RESET_HOT_KEY_ID 'strt'

static pascal OSStatus HotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void * userData) {
	EventHotKeyID hotKeyID;
	GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID) ,NULL, &hotKeyID);
	
	SSAppDelegate * appDelegate = (__bridge SSAppDelegate*)userData;
	
	if (hotKeyID.signature == START_STOP_HOT_KEY_ID) {
		[appDelegate togglePause:nil];
	}
	else if (hotKeyID.signature == RESET_HOT_KEY_ID) {
		[appDelegate resetRun:nil];
	}
	
	return noErr;
}

@implementation SSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _windowController = [[SSWindowController alloc] initWithWindowNibName:@"MainWindow"];
    _mainController = [[SSMainController alloc] init];
    _windowController.mainController = _mainController;
	
	_hotKeyEventHandler = NewEventHandlerUPP(HotKeyHandler);
	
	EventTypeSpec eventType = {
		.eventClass = kEventClassKeyboard,
		.eventKind = kEventHotKeyPressed,
	};
	
	InstallApplicationEventHandler(_hotKeyEventHandler, 1, &eventType, (__bridge void*)self, NULL);
	
	{
		EventHotKeyID startStopKeyID = {
			.signature = START_STOP_HOT_KEY_ID,
		};
		
		// F15
		RegisterEventHotKey(113, 0, startStopKeyID, GetApplicationEventTarget(), 0, &_startStopHotKeyRef);
	}
	
	{
		EventHotKeyID resetKeyID = {
			.signature = RESET_HOT_KEY_ID,
		};
		
		// F13
		RegisterEventHotKey(105, 0, resetKeyID, GetApplicationEventTarget(), 0, &_resetHotKeyRef);
	}

    // Force the controller to load (and show) the window:
    [_windowController window];
}

- (IBAction)resetRun:(id)sender
{
    [_mainController resetRun];
    [_windowController stopUpdating];
}

- (IBAction)togglePause:(id)sender
{
    if (!_mainController.running) {
        [_mainController startRun];
        [_windowController startUpdating];
    } else {
        [_mainController stopRun];
        [_windowController stopUpdating];
    }
}

@end
