//
//  SSRun.m
//  Super Splits
//
//  Created by Eric Seidel on 12/16/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRun.h"
#import "SSSplit.h"

const NSUInteger kInvalidSplitIndex = -1;

@implementation SSRun

@synthesize roomSplits=_roomSplits, events=_events;

-(id)init
{
    if (self = [super init]) {
        _roomSplits = [NSMutableArray array];
        _events = [NSMutableArray array];
    }
    return self;
}

-(id)initWithContentsOfURL:(NSURL *)url
{
    if (self = [super init]) {
        NSString *splitsString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        splitsString = [splitsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (splitsString) {
            NSArray *splitStrings = [splitsString componentsSeparatedByString:@"\n"];
            // This is the hacky-way to do a "map" in cocoa.
            _roomSplits = [NSMutableArray arrayWithCapacity:[splitStrings count]];
            for (NSString *splitString in splitStrings)
                [_roomSplits addObject:[[SSSplit alloc] initWithString:splitString]];
            // Not saving or reading events yet.
            NSLog(@"Loaded %lu splits from path: %@", [_roomSplits count], [url path]);
        } else
            self = nil;
    }
    return self;
}

-(void)writeToURL:(NSURL *)url
{
    NSMutableString *splitsString = [[NSMutableString alloc] init];
    for (SSSplit *split in _roomSplits) {
        [splitsString appendFormat:@"%@\n", [split stringForArchiving]];
    }
    // Not saving events yet.
    NSError *error = nil;
    [splitsString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
        NSLog(@"Error saving: %@", error);
}

-(NSNumber *)timeAfterSplitAtIndex:(NSUInteger)splitIndex
{
    if (splitIndex >= [_roomSplits count])
        return nil;
    NSTimeInterval accumulatedTime = 0;
    for (size_t x = 0; x <= splitIndex; x++) {
        SSSplit *split = [_roomSplits objectAtIndex:x];
        accumulatedTime += [[split duration] doubleValue];
    }
    return [NSNumber numberWithDouble:accumulatedTime];
}

-(NSUInteger)indexOfFirstSplitAfter:(NSUInteger)startIndex withEntryMap:(NSString *)mapState scanLimit:(NSUInteger)scanLimit
{
    if (startIndex == kInvalidSplitIndex)
        startIndex = -1; // This is intentionally relying on overflow behavior to start the search at 0.
    
    for (NSUInteger splitsScanned = 0;  splitsScanned < scanLimit; splitsScanned++) {
        NSUInteger splitIndex = startIndex + splitsScanned + 1;
        if (splitIndex >= [_roomSplits count])
            break;
        
        SSSplit *split = [_roomSplits objectAtIndex:splitIndex];
        if ([split.entryMapState isEqualToString:mapState]) {
            if (splitsScanned)
                NSLog(@"WARNING: Found matching split at offset %lu from expected", splitsScanned);
            return splitIndex;
        }
        //NSLog(@"%@ does not match %@", split.entryMapState, mapState);
    }
    NSLog(@"ERROR: Split scanning limit (%lu) reached, failed to find: %@ after %lu", scanLimit, mapState, startIndex);
    return kInvalidSplitIndex;
}

@end
