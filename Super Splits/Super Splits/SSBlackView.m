//
//  SSBlackView.m
//  Super Splits
//
//  Created by Eric Seidel on 12/14/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSBlackView.h"

@implementation SSBlackView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] set];
    NSRectFill([self frame]);
}

@end
