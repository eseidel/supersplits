//
//  main.c
//  TestHarness
//
//  Created by Eric Seidel on 2/12/12.
//  Copyright (c) 2012 Eric Seidel. All rights reserved.
//

#include <stdio.h>

#include "SSTestMain.h"

int main (int argc, const char * argv[])
{
    // FIXME: We may need to make this fancier and actually run a RunLoop.
    @autoreleasepool {
        SSTestMain *testMain = [SSTestMain new];
        NSMutableArray *args = [NSMutableArray arrayWithCapacity:argc];
        // Skip the first argument (the executable name)
        for (NSUInteger i = 1; i < argc; i++)
            [args addObject:[NSString stringWithUTF8String:argv[i]]];
        return [testMain runWithArgs:args]; 
    }
}
