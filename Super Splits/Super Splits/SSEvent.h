//
//  SSEvent.h
//  Super Splits
//
//  Created by Eric Seidel on 12/17/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    InvalidEvent,
    RoomEvent,
    DoorEvent,
    MapChangeEvent,
    CutsceneEvent,
    ItemEvent,
    PauseEvent,
} SSEventType;

// Events mark the start of states.
@interface SSEvent : NSObject

@property SSEventType type;
@property (readonly) NSString *typeName;
@property (retain) NSNumber *offset;
@property (retain) NSImage *image;

@end