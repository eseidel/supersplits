//
//  SSRun.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSRunController : NSObject
{
    NSDate *_overallStart;
    NSDate *_roomStart;
    NSDate *_transitionStart;

    NSMutableArray *_roomSplits;
}

@property (readonly) NSDate *startTime;

-(void)startRoom;
-(BOOL)inTransition;
-(void)startTransition;
-(void)endTransition;

-(NSNumber *)lastRoomSplit;
-(NSNumber *)roomTime;
-(NSNumber *)totalTime;
@end
