//
//  SSAppDelegate.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSAppDelegate.h"

@implementation SSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _windowController = [[SSWindowController alloc] initWithWindowNibName:@"MainWindow"];
    _mainController = [[SSMainController alloc] init];
    _windowController.mainController = _mainController;

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
