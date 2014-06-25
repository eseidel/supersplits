//
//  SSRunBuilderTest.m
//  Super Splits
//
//  Created by Eric Seidel on 12/26/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSRunBuilderTest.h"
#import "SSRunBuilder.h"

@implementation SSRunBuilderTest

- (void)testInit
{
    SSRunBuilder *runBuilder = [[SSRunBuilder alloc] init];
    XCTAssertEqual(runBuilder.state, UnknownState, @"SSRunBuilder starts at unknown");
}

@end
