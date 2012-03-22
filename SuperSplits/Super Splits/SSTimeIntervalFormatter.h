//
//  SSTimeIntervalFormatter.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSTimeIntervalFormatter : NSFormatter

// FIXME: This isn't a very flexible design.
@property BOOL hideDeciseconds;

- (NSString *)stringForObjectValue:(id)anObject;

@end
