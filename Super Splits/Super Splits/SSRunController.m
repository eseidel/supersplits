//
//  SSRun.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRunController.h"

@interface SSRunController (PrivateMethods)

-(void)_startRoom;
-(void)_recordLastRoom;

@end

const SSRoomId kInvalidRoomId = (SSRoomId)-1;

@implementation SSRunController

@synthesize startTime=_overallStart, roomSplits=_roomSplits, state=_state;

-(NSString *)stringForState:(SSRunState)state
{
    switch(state) {
        case RoomState:
            return @"Room";
        case RoomTransitionState:
            return @"Door";
        case BlackScreenState:
            return @"Cutscene";
        case UnknownState:
            return @"Ready";
    }
    return @"Invalid state!";
}

-(NSString *)stateAsString
{
    return [self stringForState:_state];
}

-(void)setState:(SSRunState)newState
{
    // FIXME: Should we do this with KVO instead of a manual setter?
    if (newState == _state)
        return;

    // Ignore any transition from unknown unless it's to "room".
    if (_state == UnknownState) {
        if (newState != RoomState)
            return;
        _overallStart = [NSDate date];
        _roomSplits = [NSMutableArray array];
        [self _startRoom];
    }

    NSTimeInterval stateDuration = -[_stateStart timeIntervalSinceNow];
    NSLog(@"%@ (%.2fs) -> %@", [self stringForState:_state], stateDuration, [self stringForState:newState]);

    if (newState == RoomState) {
        if (_state == RoomTransitionState) {
            if (stateDuration < 1.0)
                NSLog(@"WARNING: Ignoring short door transition? Assuming just a very black room.");
            else
                [self _startRoom];
        }
        if ((_state == BlackScreenState) && (stateDuration > 2.0)) {
            // This is used to differentiate between cut-scenes and black screens for pause.
            [self _startRoom];
        }
    }
    _stateStart = [NSDate date];
    _state = newState;
}

+(NSArray *)runFileTypes
{
    return [NSArray arrayWithObject:@"txt"];
}

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(id)initWithContentsOfURL:(NSURL *)url
{
    if (self = [super init]) {
        // FIXME: We're abusing this class as both a controller and model!
        NSString *splitsString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        splitsString = [splitsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (splitsString) {
            NSArray *splitStrings = [splitsString componentsSeparatedByString:@"\n"];
            // This is the hacky-way to do a "map" in cocoa.
            _roomSplits = [splitStrings valueForKey:@"doubleValue"];
            NSLog(@"Loaded splits: %@ from path: %@", _roomSplits, [url path]);
        } else
            self = nil;
    }
    return self;
}

-(void)writeToURL:(NSURL *)url
{
    NSMutableString *splitsString = [[NSMutableString alloc] init];
    for (NSNumber *splitTime in _roomSplits) {
        [splitsString appendFormat:@"%.2f\n", [splitTime doubleValue]];
    }
    NSError *error = nil;
    [splitsString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
        NSLog(@"Error saving: %@", error);
}

-(void)_startRoom
{
    if (_stateStart) {
        NSNumber *roomSplit = [self roomTime];
        double roomSplitDouble = [roomSplit doubleValue];
        if (roomSplitDouble < 1.0) { // FIXME: Is this too short for the shortest real room?
            NSLog(@"Ignoring short room-split: %.2fs. Cut-scene? Backtracking?", roomSplitDouble);
        } else {
            [_roomSplits addObject:roomSplit];
            NSTimeInterval transitionTime = -[_stateStart timeIntervalSinceNow];
            NSLog(@"Split: %.2fs, Transition: %.2fs", roomSplitDouble, transitionTime);
            [self autosave];
        }
    }
    _roomStart = [NSDate date];
}

-(NSNumber *)roomTime
{
    NSTimeInterval roomTime;
    if (_state != RoomState)
        roomTime = [_stateStart timeIntervalSinceDate:_roomStart];
    else
        roomTime = -[_roomStart timeIntervalSinceNow];
    return [NSNumber numberWithDouble:roomTime];
}

-(NSNumber *)totalTime
{
    return [NSNumber numberWithDouble:-[_overallStart timeIntervalSinceNow]];
}

-(SSRoomId)lastRoomId
{
    if (!_roomSplits || ![_roomSplits count])
        return kInvalidRoomId;
    return [_roomSplits count];
}

-(SSRoomId)currentRoomId
{
    // FIXME: Should we always return a value here?
    return [_roomSplits count] + 1;
}

-(void)autosave
{
    NSString *runsDirectory = @"~/Library/Application Support/Super Splits";
    runsDirectory = [runsDirectory stringByExpandingTildeInPath];
    NSURL *runsURL = [NSURL fileURLWithPath:runsDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtURL:runsURL withIntermediateDirectories:YES attributes:nil error:nil];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy hh:mma"];
    NSString *dateString = [dateFormat stringFromDate:_overallStart];

    NSString *runName = [NSString stringWithFormat:@"%@ Autosave.txt", dateString];
    NSURL *runURL = [runsURL URLByAppendingPathComponent:runName];
    [self writeToURL:runURL];
}

-(NSNumber *)timeAfterRoom:(SSRoomId)roomId
{
    if (roomId > [_roomSplits count] || roomId == kInvalidRoomId)
        return nil;
    NSTimeInterval accumulatedTime = 0;
    for (size_t x = 0; x < roomId; x++)
        accumulatedTime += [[_roomSplits objectAtIndex:x] doubleValue];
    return [NSNumber numberWithDouble:accumulatedTime];
}

-(NSNumber *)splitForRoom:(SSRoomId)roomId
{
    if (roomId > [_roomSplits count] || roomId == kInvalidRoomId)
        return nil;
    return [_roomSplits objectAtIndex:roomId - 1];
}

@end
