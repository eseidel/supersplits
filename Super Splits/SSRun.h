//
//  SSRun.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSRun : NSObject
{
    NSDate *_overallStart;
    NSDate *_roomStart;
    NSDate *_transitionStart;
    
    NSMutableArray *_roomSplits;
}

@property (readonly) NSDate *startTime;

-(void)writeToURL:(NSURL *)url;

-(void)startRoom;
-(BOOL)inTransition;
-(void)startTransition;
-(void)endTransition;

-(NSNumber *)lastRoomSplit;
-(NSNumber *)roomTime;
-(NSNumber *)totalTime;
@end
