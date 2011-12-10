//
//  SSTimeIntervalFormatter.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSTimeIntervalFormatter.h"

@implementation SSTimeIntervalFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
    NSTimeInterval timeInterval = [anObject doubleValue];

    int secondsRemaining = abs(timeInterval);
    int hours = secondsRemaining / 3600;
    secondsRemaining -= ( hours * 3600 );
    int minutes = secondsRemaining / 60;
    secondsRemaining -= ( minutes * 60 );
    int seconds = secondsRemaining;
    int deciseconds = abs((timeInterval - trunc(timeInterval)) * 10.0);
    int sign = timeInterval < 0 ? -1 : 1;

    if (hours > 0)
        return [NSString stringWithFormat:@"%d%02d:%02d.%ds", sign * hours, minutes, seconds, deciseconds];
    if (minutes > 0)
        return [NSString stringWithFormat:@"%d:%02d.%ds", sign * minutes, seconds, deciseconds];
    return [NSString stringWithFormat:@"%d.%ds", sign * seconds, deciseconds];
}

@end
