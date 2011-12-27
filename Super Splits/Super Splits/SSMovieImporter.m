//
//  SSMovieImporter.m
//  Super Splits
//
//  Created by Eric Seidel on 12/19/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMovieImporter.h"
#import "SSMetroidFrame.h"
#import "SSRunBuilder.h"
#import "SSRunDocument.h"

#import <QTKit/QTKit.h>
#import "SSMovieImportOperation.h"
#import "SSImportWindowController.h"

@implementation SSMovieImporter

@synthesize importOperation=_importOperation, progress=_progress;

-(id)init
{
    if (self = [super init]) {
        _importQueue = [NSOperationQueue new];
        // FIXME: Unclear if setMaxConcurrentOperationCount is needed here.
        [_importQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

+(NSArray *)movieFileTypes
{
    return [QTMovie movieFileTypes:QTIncludeAllTypes];
}

-(void)scanRunFromMovieURL:(NSURL *)url
{
    NSError *error = nil;
    QTMovie *movie = [QTMovie movieWithURL:url error:&error];
    if (error) {
        NSLog(@"Error creating QTMovie: %@ from: %@", error, url);
        return;
    }

    BOOL success = [movie detachFromCurrentThread];
    if (!success) {
        NSLog(@"Failed to detatch QTMovie: %@ from current thread", url);
        return;
    }

    _importOperation = [[SSMovieImportOperation alloc] initWithMovie:movie importer:self];
    __weak SSMovieImportOperation *weakOperation = _importOperation;
    __weak SSImportWindowController *weakWindowController = _importWindowController;
    _importOperation.completionBlock = ^(void) {
        [[weakWindowController window] close];
        if (!weakOperation || weakOperation.isCancelled)
            return;
        NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
        NSError *error = nil;
        SSRunDocument *document = [documentController openUntitledDocumentAndDisplay:YES error:&error];
        if (error) {
            NSLog(@"Error creating run document after import: %@", error);
            return;
        }
        document.run = weakOperation.completedRun;
    };
    [_importQueue addOperation:_importOperation];

    _importWindowController = [[SSImportWindowController alloc] initWithWindowNibName:@"ImportWindow"];
    _importWindowController.movieImporter = self;
    // FIXME: Should this be a modal window?
    [[_importWindowController window] makeKeyAndOrderFront:self];
}

@end
