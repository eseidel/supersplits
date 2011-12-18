//
//  SSAppDelegate.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSAppDelegate.h"

#import "SSCoreDataController.h"
#import "SSDebugWindowController.h"
#import "SSHistoryWindowController.h"
#import "SSMainController.h"
#import "SSRun.h"
#import "SSRunBuilder.h"
#import "SSTimerWindowController.h"
#import "SSUserDefaults.h"

#import <QTKit/QTKit.h>
#import "SSMovieImageSource.h"

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

- (void)_registerDefaults
{
    NSDictionary *defaultsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                             forKey:kSpeedMultiplierDefaultName];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDict];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self _registerDefaults];

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
		EventHotKeyID startStopKeyID = { .signature = START_STOP_HOT_KEY_ID };
		// F15
		RegisterEventHotKey(113, 0, startStopKeyID, GetApplicationEventTarget(), 0, &_startStopHotKeyRef);
	}
	{
		EventHotKeyID resetKeyID = { .signature = RESET_HOT_KEY_ID };
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
    if (![_mainController running]) {
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
        _debugWindowController.mainController = _mainController;
    }
    [[_debugWindowController window] makeKeyAndOrderFront:self];
}

- (IBAction)showHistoryWindow:(id)sender
{
    if (!_historyWindowController) {
        _historyWindowController = [[SSHistoryWindowController alloc] initWithWindowNibName:@"HistoryWindow"];
        _historyWindowController.coreDataController = _coreDataController;
        _historyWindowController.mainController = _mainController;
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

- (IBAction)saveAs:(id)sender
{
    if ([_mainController running])
        [_mainController stopRun]; // If we're going to show a modal panel, might as well stop the run._

    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:[SSRun runFileTypes]];
    NSInteger saveChoice = [savePanel runModal];
    if (saveChoice != NSFileHandlingPanelOKButton)
        return;

    [[[_mainController runBuilder] run] writeToURL:[savePanel URL]];
}

- (IBAction)saveAsReference:(id)sender
{
    if ([_mainController running])
        [_mainController stopRun];

    [[[_mainController runBuilder] run] writeToURL:[_mainController referenceRunURL]];
}

- (IBAction)loadReferenceRun:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[SSRun runFileTypes]];
    NSInteger openChoice = [openPanel runModal];
    if (openChoice != NSFileHandlingPanelOKButton)
        return;

    SSRun *referenceRun = [[SSRun alloc] initWithContentsOfURL:[openPanel URL]];
    _mainController.referenceRun = referenceRun;
}

- (IBAction)importFromMovie:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[QTMovie movieFileTypes:QTIncludeAllTypes]];
    NSInteger openChoice = [openPanel runModal];
    if (openChoice != NSFileHandlingPanelOKButton)
        return;
    
//    SSMovieImageSource *imageSource = [[SSMovieImageSource alloc] init];
//    imageSource.delegate = 
    // FIXME: We need to break RunController out of MainController and make it
    // not rely on realtime before this can work.
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
