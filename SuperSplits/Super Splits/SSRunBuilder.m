//
//  SSRunBuilder.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRunBuilder.h"

#import "SSEvent.h"
#import "SSMetroidFrame.h"
#import "SSRun.h"
#import "SSSplit.h"

@interface SSRunBuilder (PrivateMethods)

-(void)_startRoom;
-(void)_recordLastRoom;
-(NSTimeInterval)_stateTime;

@end

@implementation SSRunBuilder

@synthesize run=_run, state=_state, offset=_offset, currentSplit=_currentSplit;

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
    event.offset = _offset;
    return event;
}

-(void)_updateMinimapState:(NSString *)newMapState
{
    NSString *lastMapState = _mapState;
    _mapState = newMapState;
    if (_currentSplit.entryMapState)
        return;

    BOOL mapWaitTimeout = [self roomTime] > 1.0;
    if ([lastMapState isEqualToString:_mapState] && !mapWaitTimeout)
        return;

    // If it's been more than a second, assume that we already have
    // the right minimap for this room, even if its the same as the last.
    if (mapWaitTimeout)
        NSLog(@"WARNING: No new mapState 1s after door transition, using %@", _mapState);
    _currentSplit.entryMapState = _mapState;
}

-(void)updateWithFrame:(SSMetroidFrame *)frame atOffset:(NSTimeInterval)offset
{
    self.offset = offset;

    if (frame.isMissingEnergyText) {
        self.state = BlackScreenState;
    } else if (frame.isMostlyBlack) {
        self.state = RoomTransitionState;
    } else if (frame.isItemScreen) {
        self.state = ItemScreenState;
    } else {
        self.state = RoomState;
        [self _updateMinimapState:frame.miniMapString];
    }
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

-(id)init
{
    if (self = [super init]) {
        _run = [[SSRun alloc] init];
    }
    return self;
}

-(void)_saveSplitFromLastRoom
{
    assert(_stateStart);
    NSTimeInterval roomTime = [self roomTime];
    // FIXME: Does this check belong here instead of in setState?
    if (roomTime < 1.0) { // FIXME: Is this too short for the shortest real room?
        NSLog(@"Ignoring short room-split: %.2fs. Cut-scene? Backtracking?", roomTime);
        return;
    }

    _currentSplit.duration = roomTime;
    _currentSplit.exitMapState = _mapState;
    if (!_currentSplit.entryMapState)
        _currentSplit.entryMapState = _mapState;

    // We could turn this assert into an if, to allow "reopening" rooms?
    assert(![[_run roomSplits] containsObject:_currentSplit]);
    [[_run roomSplits] addObject:_currentSplit];
    NSLog(@"Saving Split: %.2fs, %@ -> %@, Transition: %.2fs", roomTime, _currentSplit.entryMapState, _currentSplit.exitMapState, [self _stateTime]);
    // We don't currently nil _currentSplit, but perhaps we should?
    [_run autosave];
}

-(void)_startRoom
{
    if (_stateStart)
        [self _saveSplitFromLastRoom];

    // Super Metroid doesn't update the minimap until *after* the door animation completes.
    // Our room transition detection currently thinks the door animation ends slightly
    // before it does.  So instead of setting _currentSplit.entryMapState = _mapState here,
    // we update it only if/when the map ever changes inside this room.
    // If the map never changes, then when we record the room we'll use the ending
    // state for the previous room.
    _currentSplit = [[SSSplit alloc] init];
    _currentSplit.offset = _offset;
}

-(NSTimeInterval)roomTime
{
    if (_state == UnknownState)
        return 0;

    if (_state != RoomState)
        return _stateStart - _currentSplit.offset;

    return _offset - _currentSplit.offset;
}

-(NSTimeInterval)totalTime
{
    if (_state == UnknownState)
        return 0;

    return _offset - _startOffset;
}

-(NSTimeInterval)_stateTime
{
    return _offset - _stateStart;
}

@end
