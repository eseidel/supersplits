//
//  SSSplit.m
//  Super Splits
//
//  Created by Eric Seidel on 12/13/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSSplit.h"

@implementation SSSplit

@synthesize entryMapState=_entryMapState, exitMapState=_exitMapState, duration=_duration;

-(id)initWithString:(NSString *)archiveString
{
    if (self = [super init]) {
        _duration = [NSNumber numberWithDouble:[archiveString doubleValue]];
    }
    return self;
}

-(NSString *)stringForArchiving
{
    return [NSString stringWithFormat:@"%.2f", _duration];
}

@end
