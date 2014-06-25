//
//  SSRunDocument.m
//  Super Splits
//
//  Created by Eric Seidel on 12/25/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRunDocument.h"
#import "SSRun.h"
#import "SSSplitMatcher.h"

@implementation SSRunDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"SSRunDocument";
}

-(NSURL *)referenceRunURL
{
    return [SSRun defaultURLForRunWithName:@"reference"];
}

- (SSRun *)referenceRun
{
    return [[SSRun alloc] initWithContentsOfURL:[self referenceRunURL]];
}

- (NSArray *)matchedSplits
{
    SSSplitMatcher *matcher = [[SSSplitMatcher alloc] init];
    NSArray *matchedSplits = [matcher matchSplitsFromRun:self.run withReferenceRun:self.referenceRun];
    return [matcher fillInGaps:matchedSplits fromReferenceRun:self.referenceRun];
}

+ (NSSet *)keyPathsForValuesAffectingMatchedSplits
{
    return [NSSet setWithObjects:@"run", @"referenceRun", nil];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [_run writeToData];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    _run = [[SSRun alloc] initWithData:data];
    return !!_run;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

@end
