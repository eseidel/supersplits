//
//  SSImportWindowController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/26/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSImportWindowController.h"
#import "SSMovieImporter.h"
#import "SSMovieImportOperation.h"

@implementation SSImportWindowController

@synthesize movieImporter=_movieImporter;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)cancelImport:(id)sender
{
    NSLog(@"Canceling import");
    [_movieImporter.importOperation cancel];
    [self.window close];
}

@end
