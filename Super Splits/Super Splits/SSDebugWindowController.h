//
//  SSDebugWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SSDebugWindowController : NSWindowController
{
    IBOutlet NSImageView *_debugImage;
}

@property (readonly) NSImageView *debugImageView;

@end
