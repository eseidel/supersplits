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
    _timerWindowController = [[SSTimerWindowController alloc] initWithWindowNibName:@"MainWindow"];
    _mainController = [[SSMainController alloc] init];
    _timerWindowController.mainController = _mainController;
    _coreDataController = [[SSCoreDataController alloc] init];

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
    [_timerWindowController window];
}

- (IBAction)resetRun:(id)sender
{
    [_mainController resetRun];
    [_timerWindowController stopUpdating];
}

- (IBAction)togglePause:(id)sender
{
    if (!_mainController.running) {
        [_mainController startRun];
        [_timerWindowController startUpdating];
    } else {
        [_mainController stopRun];
        [_timerWindowController stopUpdating];
    }
}

- (IBAction)showDebugWindow:(id)sender
{
    if (!_debugWindowController) {
        _debugWindowController = [[SSDebugWindowController alloc] initWithWindowNibName:@"DebugWindow"];
        [_debugWindowController window]; // Load the window.
        [_mainController setDebugImageView:[_debugWindowController debugImageView]];
    }
    [[_debugWindowController window] makeKeyAndOrderFront:self];
}

- (IBAction)showHistoryWindow:(id)sender
{
    if (!_historyWindowController) {
        _historyWindowController = [[SSHistoryWindowController alloc] initWithWindowNibName:@"HistoryWindow"];
        _historyWindowController.coreDataController = _coreDataController;
    }
    [[_historyWindowController window] makeKeyAndOrderFront:self];
}

/**
 Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[_coreDataController managedObjectContext] undoManager];
}

- (IBAction)saveAction:(id)sender
{	
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSInteger saveChoice = [savePanel runModal];
    if (saveChoice != NSFileHandlingPanelOKButton)
        return;
    
    [[_mainController currentRun] writeToURL:[savePanel URL]];
}

/**
 Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)coreData_saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[_coreDataController managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[_coreDataController managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)coreData_applicationShouldTerminate:(NSApplication *)sender
{
    return [_coreDataController applicationShouldTerminate:sender];
}

@end
