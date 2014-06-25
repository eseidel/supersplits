//
//  SSEvent.m
//  Super Splits
//
//  Created by Eric Seidel on 12/17/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSEvent.h"

@implementation SSEvent

-(id)initWithType:(SSEventType)type atOffset:(NSTimeInterval)offset
{
    self = [super init];
    if (self) {
        _type = type;
        _offset = offset;
    }
    return self;
}

-(NSString *)typeName
{
    NSString * typeName = @"ERROR";
    
    switch(_type) {
        case RoomEvent:
            typeName = @"room";
            break;
        case DoorEvent:
            typeName = @"door";
            break;
        case CutsceneEvent:
            typeName = @"cutscene";
            break;
        case ItemEvent:
            typeName = @"item";
            break;
        case MapChangeEvent:
            typeName = @"map";
            break;
        case PauseEvent:
            typeName = @"pause";
            break;
        case InvalidEvent:
            typeName = @"invalid";
            break;
    }
    return typeName;
}

@end
