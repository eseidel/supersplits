//
//  SSRunBuilder.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRunBuilder.h"

#import "SSEvent.h"
#import "SSRun.h"
#import "SSSplit.h"

@interface SSRunBuilder (PrivateMethods)

-(void)_startRoom;
-(void)_recordLastRoom;
-(NSTimeInterval)_stateTime;

@end

@implementation SSRunBuilder

@synthesize currentRun=_run, state=_state, offset=_offset,
            mapState=_mapState, roomEntryMapState=_roomEntryMapState;


-(NSString *)stringForState:(SSRunState)state
{
    switch(state) {
        case RoomState:
            return @"Room";
        case RoomTransitionState:
            return @"Door";
        case BlackScreenState:
            return @"Cutscene";
        case ItemScreenState:
            return @"Item";
        case UnknownState:
            return @"Ready";
    }
    return @"Invalid state!";
}

-(NSString *)stateAsString
{
    return [self stringForState:_state];
}

-(SSEvent *)createEventForNewState:(SSRunState)newState
{
    SSEvent *event = [[SSEvent alloc] init];
    switch (newState) {
        case RoomState:
            event.type = RoomEvent;
            break;
        case RoomTransitionState:
            event.type = DoorEvent;
            break;
        case BlackScreenState:
            event.type = CutsceneEvent;
            break;
        case ItemScreenState:
            event.type = ItemEvent;
            break;
        default:
            event.type = InvalidEvent;
    }
    event.offset = [NSNumber numberWithDouble:_offset];
    return event;
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
        // FIXME: When we detect the first room is actually about 3s after
        // the conventional start of a speed run.
        _startOffset = _offset;
        _run = [[SSRun alloc] init];
        [self _startRoom];
    }

    NSTimeInterval stateDuration = [self _stateTime];
    NSLog(@"%@ (%.2fs) -> %@", [self stringForState:_state], stateDuration, [self stringForState:newState]);

    if (newState == RoomState) {
        if (_state == RoomTransitionState) {
            if (stateDuration < 1.0)
                NSLog(@"WARNING: Ignoring short (%.2f) door transition? Assuming just a very black room.", stateDuration);
            else
                [self _startRoom];
        }
        if ((_state == BlackScreenState) && (stateDuration > 2.0)) {
            // This is used to differentiate between cut-scenes and black screens for pause.
            [self _startRoom];
        }
    }
    [_run.events addObject:[self createEventForNewState:newState]];
    _stateStart = _offset;
    _state = newState;
}

-(void)setMapState:(NSString *)mapState
{
    // FIXME: Should we do this with KVO instead of a manual setter?
    if ([_mapState isEqualToString:mapState]) {
        if (!_roomEntryMapState && [[self roomTime] doubleValue] > 1.0) {
            // If it's been more than a second, assume that we already have
            // the right minimap for this room, even if its the same as the last.
            NSLog(@"WARNING: No new mapState 1s after door transition, using current %@", _mapState);
            _roomEntryMapState = _mapState;
        }
        return;
    }

    //NSLog(@"Map: %@ -> %@", _mapState, mapState);
    _mapState = mapState;
    if (!_roomEntryMapState) {
        //NSLog(@"Entry Map State: %@, %.2fs after door", _mapState, [[self roomTime] doubleValue]);
        _roomEntryMapState = _mapState;
    }
}

-(id)init
{
    if (self = [super init]) {
        _run = [[SSRun alloc] init];
    }
    return self;
}

-(void)_startRoom
{
    if (_stateStart) {
        NSNumber *roomTime = [self roomTime];
        double roomTimeDouble = [roomTime doubleValue];
        // FIXME: Does this check belong here instead of in setState?
        if (roomTimeDouble < 1.0) { // FIXME: Is this too short for the shortest real room?
            NSLog(@"Ignoring short room-split: %.2fs. Cut-scene? Backtracking?", roomTimeDouble);
        } else {
            SSSplit *split = [[SSSplit alloc] init];
            split.duration = roomTime;
            split.entryMapState = _roomEntryMapState;
            // We're careful in SSMainController to set the current state before setting the new
            // map state, so we can use _mapState here as the exit map state.
            split.exitMapState = _mapState;

            [[_run roomSplits] addObject:split];
            NSLog(@"Saving Split: %.2fs, %@ -> %@, Transition: %.2fs", roomTimeDouble, split.entryMapState, split.exitMapState, [self _stateTime]);
            [_run autosave];
        }
    }

    // Super Metroid doesn't update the minimap until *after* the door animation completes.
    // Our room transition detection currently thinks the door animation ends slightly
    // before it does.  So instead of setting _roomEntryMapState = _mapState here, we
    // set it to nil and update it if/when the map ever changes inside this room.
    // If the map never changes, then when we record the room we'll use the ending
    // state for the previous room.
    _roomEntryMapState = nil;
    _roomStart = _offset;
}

-(NSNumber *)roomTime
{
    if (_state == UnknownState)
        return nil;

    NSTimeInterval roomTime;
    if (_state != RoomState)
        roomTime = _stateStart - _roomStart;
    else
        roomTime = _offset - _roomStart;
    return [NSNumber numberWithDouble:roomTime];
}

-(NSNumber *)totalTime
{
    if (_state == UnknownState)
        return nil;
    return [NSNumber numberWithDouble:_offset - _startOffset];
}

-(NSTimeInterval)_stateTime
{
    return _offset - _stateStart;
}

@end
