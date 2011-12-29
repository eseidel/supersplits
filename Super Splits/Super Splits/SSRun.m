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

@synthesize roomSplits=_roomSplits, events=_events, url=_url;

+(NSArray *)runFileTypes
{
    return [NSArray arrayWithObject:@"txt"];
}

+(NSURL *)defaultRunsDirectory
{
    NSString *runsDirectory = @"~/Library/Application Support/Super Splits";
    runsDirectory = [runsDirectory stringByExpandingTildeInPath];
    NSURL *runsURL = [NSURL fileURLWithPath:runsDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtURL:runsURL withIntermediateDirectories:YES attributes:nil error:nil];
    return runsURL;
}

+(NSURL *)defaultURLForRunWithName:(NSString *)name
{
    NSString *filename = [name stringByAppendingPathExtension:@"txt"];
    return [[SSRun defaultRunsDirectory] URLByAppendingPathComponent:filename];
}

-(id)init
{
    if (self = [super init]) {
        _startDate = [NSDate date];
        _roomSplits = [NSMutableArray array];
        _events = [NSMutableArray array];
    }
    return self;
}

-(id)initWithContentsOfURL:(NSURL *)url
{
    self = [self initWithData:[NSData dataWithContentsOfURL:url]];
    if (!self)
        return nil;
    _url = url;
    NSLog(@"Loaded %lu splits from path: %@", [_roomSplits count], [url path]);
    return self;
}

-(id)initWithData:(NSData *)data
{
    self = [super init];
    if (!self)
        return nil;

    NSString *splitsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    splitsString = [splitsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!splitsString)
        return nil;

    NSArray *splitStrings = [splitsString componentsSeparatedByString:@"\n"];
    _roomSplits = [NSMutableArray arrayWithCapacity:[splitStrings count]];
    for (NSString *splitString in splitStrings)
        [_roomSplits addObject:[[SSSplit alloc] initWithString:splitString]];
    // Not saving or reading events yet.

    return self;
}

-(NSData *)writeToData
{
    NSMutableString *splitsString = [[NSMutableString alloc] init];
    for (SSSplit *split in _roomSplits) {
        [splitsString appendFormat:@"%@\n", [split stringForArchiving]];
    }
    return [splitsString dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSString *)filename
{
    return [_url lastPathComponent];
}

-(void)writeToURL:(NSURL *)url
{
    NSData *data = [self writeToData];
    NSError *error = nil;
    [data writeToURL:url options:NSDataWritingAtomic error:&error];
    if (error)
        NSLog(@"Error (%@) writing to url: %@", error, url);
    if (!_url)
        _url = url;
}

-(NSNumber *)timeAfterSplitAtIndex:(NSUInteger)splitIndex
{
    if (splitIndex >= [_roomSplits count])
        return nil;
    NSTimeInterval accumulatedTime = 0;
    for (size_t x = 0; x <= splitIndex; x++) {
        SSSplit *split = [_roomSplits objectAtIndex:x];
        accumulatedTime += [split duration];
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

-(NSString *)autosaveName
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy hh:mma"];
    NSString *dateString = [dateFormat stringFromDate:_startDate];
    return [NSString stringWithFormat:@"%@ Autosave", dateString];
}

-(void)autosave
{
    if (!_url)
        [self writeToURL:[SSRun defaultURLForRunWithName:[self autosaveName]]];

    [self writeToURL:_url];
}

@end
