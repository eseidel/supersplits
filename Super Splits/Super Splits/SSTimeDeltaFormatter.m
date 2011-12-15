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
    if (timeInterval >= 0.0)
        return [@"+" stringByAppendingString:formattedString];
    // Negative values will already have their - from SSTimeIntervalFormatter.
    return formattedString;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)attrs
{
    NSString *string = [self stringForObjectValue:obj];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string attributes:attrs];
    // FIXME: This is a bit of a hack, SSTimeDeltaFormatter should not hard-code the precision.
    // This is to avoid seeing -0.0 in red.
    if ([obj doubleValue] > 0.1)
        [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [string length])];
    return attrString;
}

@end
