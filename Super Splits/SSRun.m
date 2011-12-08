//
//  SSRun.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRun.h"

@implementation SSRun

@synthesize startTime=_overallStart;

-(id)init
{
    if (self = [super init]) {
        _overallStart = [NSDate date];
        _roomStart = [NSDate date];
        _roomSplits = [NSMutableArray array];
    }
    return self;
}

-(void)writeToURL:(NSURL *)url
{
    NSMutableString *splitsString = [[NSMutableString alloc] init];
    for (NSNumber *splitTime in _roomSplits) {
        [splitsString appendFormat:@"%.2f", [splitTime doubleValue]];
    }
    [splitsString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void)startRoom
{
    if (_transitionStart) {
        NSNumber *roomSplit = [self roomTime];
        double roomSplitDouble = [roomSplit doubleValue];
        if (roomSplitDouble < 1.5) { // FIXME: Is this too short for the shortest real room?
            NSLog(@"Ignoring short room-split: %.2fs. Cut-scene? Backtracking?", roomSplitDouble);
        } else {
            [_roomSplits addObject:roomSplit];
            NSLog(@"Room split: %.2fs", roomSplitDouble);
        }
    }
    _roomStart = [NSDate date];
    _transitionStart = nil;
}

-(BOOL)inTransition
{
    return (BOOL)_transitionStart;
}

-(void)startTransition
{
    assert(![self inTransition]);
    _transitionStart = [NSDate date];
}

-(void)endTransition
{
    assert([self inTransition]);
    [self startRoom];
}

-(NSNumber *)lastRoomSplit
{
    return [_roomSplits lastObject];
}

-(NSNumber *)roomTime
{
    NSTimeInterval roomTime;
    if ([self inTransition])
        roomTime = [_transitionStart timeIntervalSinceDate:_roomStart];
    else
        roomTime = -[_roomStart timeIntervalSinceNow];
    return [NSNumber numberWithDouble:roomTime];
}

-(NSNumber *)totalTime
{
    return [NSNumber numberWithDouble:-[_overallStart timeIntervalSinceNow]];
}

@end
