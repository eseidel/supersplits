//
//  SSRunBuilder.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSMetroidFrame;
@class SSRun;

@interface SSRunBuilder : NSObject
{
    SSRun *_run;
    NSTimeInterval _offset;
    SSMetroidFrame *_frame;
}

@property (readonly) SSRun *run;
@property NSTimeInterval offset;

-(NSTimeInterval)roomTime;
-(NSTimeInterval)totalTime;

-(void)updateWithFrame:(SSMetroidFrame *)frame atOffset:(NSTimeInterval)offset;

@end
