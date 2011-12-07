//
//  SSTimeIntervalFormatter.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSTimeIntervalFormatter : NSFormatter
{
    NSDateFormatter *_hourFormatter;
    NSDateFormatter *_minuteFormatter;
    NSDateFormatter *_secondFormatter;
}

- (NSString *)stringForObjectValue:(id)anObject;

@end
