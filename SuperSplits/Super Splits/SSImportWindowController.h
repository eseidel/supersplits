//
//  SSImportWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/26/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSMovieImporter;

@interface SSImportWindowController : NSWindowController

@property (strong) SSMovieImporter *movieImporter;

-(IBAction)cancelImport:(id)sender;

@end
