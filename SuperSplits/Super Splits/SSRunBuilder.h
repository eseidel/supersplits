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
@class SSSplit;

typedef enum {
    UnknownState = 0,
    RoomState,
    RoomTransitionState,
    BlackScreenState,
    ItemScreenState,
} SSRunState;

@interface SSRunBuilder : NSObject

@property (readonly) SSRun *run;

@property NSTimeInterval offset;

@property (nonatomic) SSRunState state;
@property (readonly, nonatomic) NSString *stateAsString;

@property (strong) SSSplit *currentSplit;

-(NSTimeInterval)roomTime;
-(NSTimeInterval)totalTime;

-(void)updateWithFrame:(SSMetroidFrame *)frame atOffset:(NSTimeInterval)offset;

// For unit testing.
-(void)_updateMinimapState:(NSString *)mapState;

@end
