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
-(void)_leaveRoom;
-(void)_recordLastRoom;
-(NSTimeInterval)_stateTime;

-(void)addEvent:(SSEvent *)event;

@end

@implementation SSRunBuilder

@synthesize run=_run, offset=_offset;

-(id)init
{
    if (self = [super init]) {
        _run = [[SSRun alloc] init];
    }
    return self;
}

-(SSEventType)eventTypeFromFrame:(SSMetroidFrame *)frame
{
    assert(frame);
    if (frame.isMissingEnergyText)
        return CutsceneEvent;
    else if (frame.isMostlyBlack)
        return DoorEvent;
    else if (frame.isItemScreen)
        return ItemEvent;
    return RoomEvent;
}

-(SSEvent *)_eventForFrame:(SSMetroidFrame *)frame atOffset:(NSTimeInterval)offset
{
    SSEventType eventType = [self eventTypeFromFrame:frame];
    SSEvent *lastEvent = _run.lastEvent;

    // Ignore all events until the first room event.
    if (lastEvent.type == InvalidEvent && eventType != RoomEvent)
        return nil;

    // Map change events show up as "room events".
    if (eventType == RoomEvent && lastEvent.type == RoomEvent) {
        NSString *mapState = frame.miniMapString;
        if (mapState != _run.lastMapEvent.mapState) {
            SSEvent *event = [[SSEvent alloc] initWithType:eventType atOffset:offset];
            event.mapState = mapState;
            return event;
        }
        return nil;
    }

    // Otherwise only create events when we have a state change.
    if (eventType == _run.lastEvent.type)
        return nil;
    return [[SSEvent alloc] initWithType:eventType atOffset:offset];
}

-(void)updateWithFrame:(SSMetroidFrame *)frame atOffset:(NSTimeInterval)offset
{
    assert(frame);
    self.offset = offset;
    _frame = frame;

    SSEvent *event = [self _eventForFrame:frame atOffset:offset];
    if (event)
        [self addEvent:event];
}

-(BOOL)_shouldStartRoom:(SSEvent *)event
{
    // FIXME: Do we need code to avoid very short rooms caused by cutscene errors?
    if (event.type != RoomEvent)
        return NO;
    
    SSEvent *lastEvent = _run.lastEvent;
    NSTimeInterval stateDuration = [self _stateTime];
    if (lastEvent.type == DoorEvent && stateDuration < 1.0) {
        NSLog(@"WARNING: Ignoring short (%.2f) door transition? Assuming just a very black room.", stateDuration);
        return NO;
    }
    // This is used to differentiate between cut-scenes and black screens for pause.
    if ((lastEvent.type == CutsceneEvent) && (stateDuration < 2.0)) {
        // FIXME: we could mutate the lastEvent to be a pause event?
        return NO;
    }
    return YES;
}

-(void)addEvent:(SSEvent *)event
{
    NSTimeInterval stateDuration = [self _stateTime];
    SSEvent *lastEvent = _run.lastEvent;
    NSLog(@"%@ (%.2fs) -> %@", lastEvent.typeName, stateDuration, event.typeName);

    [_run.events addObject:event];

    SSSplit *currentRoom = [_run lastSplit];
    switch (event.type) {
        case RoomEvent:
            if ([self _shouldStartRoom:event])
                [self _startRoom];
            break;
        case MapChangeEvent:
            if (!currentRoom.entryMapState)
                currentRoom.entryMapState = event.mapState;
            break;
        case DoorEvent:
        case CutsceneEvent:
            [self _leaveRoom];
            break;
        // These are currently impossible:
        case ItemEvent:
        case PauseEvent:
        case InvalidEvent:
            assert(false);
    }
}

-(void)_leaveRoom
{
    SSSplit *split = [_run lastSplit];
    split.duration = [self roomTime];
    NSString *lastMapState = _run.lastMapEvent.mapState;
    split.exitMapState = lastMapState;
    // If we never saw a room event during this room, then we assume the
    // entry is the same is the exit, which is the same as the last room!
    if (!split.entryMapState)
        split.entryMapState = lastMapState;

    NSLog(@"Saving Split: %.2fs, %@ -> %@, Transition: %.2fs", split.duration, split.entryMapState, split.exitMapState, [self _stateTime]);
    [_run autosave];
}

-(void)_startRoom
{
    SSSplit *split = [[SSSplit alloc] init];
    [[_run roomSplits] addObject:split];
}

-(BOOL)_inRoom
{
    SSEvent *lastEvent = _run.lastEvent;
    return lastEvent && lastEvent.type != DoorEvent && lastEvent.type != CutsceneEvent;
}

-(NSTimeInterval)roomTime
{
    if ([self _inRoom])
        return _offset - _run.lastRoomEvent.offset;
    return 0;
}

-(NSTimeInterval)totalTime
{
    SSEvent * lastEvent = [_run lastEvent];
    if (lastEvent.type == InvalidEvent)
        return 0;

    return _offset - _run.firstEvent.offset;
}

-(NSTimeInterval)_stateTime
{
    // FIXME: Not all events represent state changes.
    return _offset - _run.lastEvent.offset;
}

@end
