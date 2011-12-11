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
-(BOOL)_inTransition;
-(void)_startTransition;
-(void)_endTransition;

@end

const SSRoomId kInvalidRoomId = (SSRoomId)-1;

@implementation SSRunController

@synthesize startTime=_overallStart, roomSplits=_roomSplits, state=_state;

-(void)setState:(SSRunState)state
{
    // FIXME: Should we do this with KVO instead of a manual setter?
    if (state == _state)
        return;
    _state = state;

    if (_state == TransitionState)
        [self _startTransition];
    else
        [self _endTransition];
}

+(NSArray *)runFileTypes
{
    return [NSArray arrayWithObject:@"txt"];
}

-(id)init
{
    if (self = [super init]) {
        _overallStart = [NSDate date];
        _roomStart = [NSDate date];
        _roomSplits = [NSMutableArray array];
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
    [splitsString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void)_startRoom
{
    if (_transitionStart) {
        NSNumber *roomSplit = [self roomTime];
        double roomSplitDouble = [roomSplit doubleValue];
        if (roomSplitDouble < 1.5) { // FIXME: Is this too short for the shortest real room?
            NSLog(@"Ignoring short room-split: %.2fs. Cut-scene? Backtracking?", roomSplitDouble);
        } else {
            [_roomSplits addObject:roomSplit];
            NSTimeInterval transitionTime = -[_transitionStart timeIntervalSinceNow];
            NSLog(@"Split: %.2fs, Transition: %.2fs", roomSplitDouble, transitionTime);
        }
    }
    _roomStart = [NSDate date];
    _transitionStart = nil;
}

-(BOOL)_inTransition
{
    return (BOOL)_transitionStart;
}

-(void)_startTransition
{
    assert(![self _inTransition]);
    _transitionStart = [NSDate date];
}

-(void)_endTransition
{
    assert([self _inTransition]);
    [self _startRoom];
}

-(NSNumber *)roomTime
{
    NSTimeInterval roomTime;
    if ([self _inTransition])
        roomTime = [_transitionStart timeIntervalSinceDate:_roomStart];
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
