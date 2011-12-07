//
//  SSTimeIntervalFormatter.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSTimeIntervalFormatter.h"

@implementation SSTimeIntervalFormatter

- (id)init
{
    if (self = [super init]) {
        // FIXME: There must be a cleaner way to do this.
        _hourFormatter = [[NSDateFormatter alloc] init];
        [_hourFormatter setDateFormat:@"H:mm:ss.S's'"];
        _minuteFormatter = [[NSDateFormatter alloc] init];
        [_minuteFormatter setDateFormat:@"mm:ss.S's'"];
        _secondFormatter = [[NSDateFormatter alloc] init];
        [_secondFormatter setDateFormat:@"ss.S's'"];
    }
    return self;
}

- (NSString *)stringForObjectValue:(id)anObject
{
    NSTimeInterval timeInterval = [anObject doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    if (timeInterval > 60 * 60)
        return [_hourFormatter stringFromDate:date];
    if (timeInterval > 60)
        return [_minuteFormatter stringFromDate:date];
    return [_secondFormatter stringFromDate:date];
}

@end
