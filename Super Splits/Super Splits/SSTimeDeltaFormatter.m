//
//  SSTimeDeltaFormatter.m
//  Super Splits
//
//  Created by Eric Seidel on 12/10/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSTimeDeltaFormatter.h"

@implementation SSTimeDeltaFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
    NSTimeInterval timeInterval = [anObject doubleValue];
    NSString *formattedString = [super stringForObjectValue:anObject];
    if (timeInterval >= 0)
        return [@"+" stringByAppendingString:formattedString];
    // Negative values will already have their - from SSTimeIntervalFormatter.
    return formattedString;
}

@end
