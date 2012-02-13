//
//  SSEvent.m
//  Super Splits
//
//  Created by Eric Seidel on 12/17/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSEvent.h"

@implementation SSEvent

@synthesize type=_type, offset=_offset, mapState=_mapState, image=_image;

-(id)initWithType:(SSEventType)type atOffset:(NSTimeInterval)offset
{
    if (self = [super init]) {
        _type = type;
        _offset = offset;
    }
    return self;
}

-(NSString *)typeName
{
    switch(_type) {
        case RoomEvent:
            return @"room";
        case DoorEvent:
            return @"door";
        case CutsceneEvent:
            return @"cutscene";
        case ItemEvent:
            return @"item";
        case MapChangeEvent:
            return @"map";
        case PauseEvent:
            return @"pause";
        case InvalidEvent:
            return @"invalid";
    }
    return @"ERROR";
}

@end
