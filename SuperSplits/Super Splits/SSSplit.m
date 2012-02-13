//
//  SSSplit.m
//  Super Splits
//
//  Created by Eric Seidel on 12/13/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSSplit.h"

@implementation SSSplit

@synthesize entryMapState=_entryMapState, exitMapState=_exitMapState,
            entryFrame=_entryFrame, exitFrame=_exitFrame, offset=_offset,
            duration=_duration, roomName=_roomName;

static inline NSString *nilToEmptyString(NSString *string)
{
    return string ? string : @"";
}

static inline NSString *nullOrEmptyToNil(NSString *string)
{
    if ([string isEqualToString:@"(null)"] || [string length] == 0)
        return nil;
    return string;
}

-(id)initWithString:(NSString *)archiveString
{
    if (self = [super init]) {
        // Currently this means that ':' is an invalid character for room names.
        NSArray *components = [archiveString componentsSeparatedByString:@":"];
        _duration = [[components objectAtIndex:0] doubleValue];
        if ([components count] >= 3) {
            _entryMapState = nullOrEmptyToNil([components objectAtIndex:1]);
            _exitMapState = nullOrEmptyToNil([components objectAtIndex:2]);
        }
        if ([components count] >= 4)
            _roomName = nullOrEmptyToNil([components objectAtIndex:3]);
    }
    return self;
}

-(NSString *)stringForArchiving
{
    return [NSString stringWithFormat:@"%.2f:%@:%@:%@",
            _duration,
            nilToEmptyString(_entryMapState),
            nilToEmptyString(_exitMapState),
            nilToEmptyString(_roomName),
            nil];
}

@end
