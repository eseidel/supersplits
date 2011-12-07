//
//  SSAppDelegate.h
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSMainController.h"

@interface SSAppDelegate : NSObject <NSApplicationDelegate>
{
    SSMainController *_mainController;
}
@property (assign) IBOutlet NSWindow *window;

@end
