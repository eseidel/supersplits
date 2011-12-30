//
//  SSRunDocument.h
//  Super Splits
//
//  Created by Eric Seidel on 12/25/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSRun;

@interface SSRunDocument : NSDocument

@property (retain) SSRun *run;
@property (readonly) NSArray *matchedSplits;

@end
