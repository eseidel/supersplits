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
            entryFrame=_entryFrame, exitFrame=_exitFrame,
            duration=_duration;

-(id)initWithString:(NSString *)archiveString
{
    if (self = [super init]) {
        NSArray *components = [archiveString componentsSeparatedByString:@":"];
        _duration = [NSNumber numberWithDouble:[[components objectAtIndex:0] doubleValue]];
        if ([components count] == 3) {
            _entryMapState = [components objectAtIndex:1];
            _exitMapState = [components objectAtIndex:2];
        }
    }
    return self;
}

-(NSString *)stringForArchiving
{
    return [NSString stringWithFormat:@"%.2f:%@:%@", [_duration doubleValue], _entryMapState, _exitMapState, nil];
}

@end
