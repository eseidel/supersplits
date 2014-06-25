//
//  SSEvent.h
//  Super Splits
//
//  Created by Eric Seidel on 12/17/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    InvalidEvent = 0,
    RoomEvent,
    DoorEvent,
    MapChangeEvent,
    CutsceneEvent,
    ItemEvent,
    PauseEvent,
} SSEventType;

// Events mark the start of states.
@interface SSEvent : NSObject

-(id)initWithType:(SSEventType)type atOffset:(NSTimeInterval)offset;

@property SSEventType type;
@property (readonly, nonatomic) NSString *typeName;
@property (strong) NSString *mapState;
@property NSTimeInterval offset;
@property (strong) NSImage *image;

@end
