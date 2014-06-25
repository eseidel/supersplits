//
//  SSTimerWindowController.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SSMainController;

@interface SSTimerWindowController : NSWindowController

@property(weak, nonatomic) IBOutlet NSTextField *totalTimeView;
@property(weak, nonatomic) IBOutlet NSTextField *totalTimeDeltaView;
@property(weak, nonatomic) IBOutlet NSTextField *timerState;
@property(weak, nonatomic) IBOutlet NSTextField *roomNameView;
@property(weak, nonatomic) IBOutlet NSTextField *speedMultiplierView;

@property(retain) SSMainController *mainController;

-(void)startUpdating;
-(void)stopUpdating;
-(void)updateTimerViews;

@end
