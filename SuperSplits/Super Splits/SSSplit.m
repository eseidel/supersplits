//
//  SSSplit.m
//  Super Splits
//
//  Created by Eric Seidel on 12/13/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSSplit.h"

@implementation SSSplit

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
    self = [super init];
    if (self) {
        // Currently this means that ':' is an invalid character for room names.
        NSArray *components = [archiveString componentsSeparatedByString:@":"];
        _duration = [components[0] doubleValue];
        if ([components count] >= 3) {
            _entryMapState = nullOrEmptyToNil(components[1]);
            _exitMapState = nullOrEmptyToNil(components[2]);
        }
        if ([components count] >= 4)
            _roomName = nullOrEmptyToNil(components[3]);
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
