//
//  SSTimeIntervalFormatter.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Google. All rights reserved.
//

#import "SSTimeIntervalFormatter.h"

@implementation SSTimeIntervalFormatter

- (id)init
{
    if (self = [super init]) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"mm:ss.S"];
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)anObject
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[anObject doubleValue]];
    return [_dateFormatter stringFromDate:date];
}

@end
