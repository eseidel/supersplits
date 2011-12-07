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
    // Insert code here to initialize your application
    _windowController = [[SSWindowController alloc] initWithWindowNibName:@"MainWindow"];
    // Force the controller to load (and show) the window:
    [_windowController window];
}

@end
