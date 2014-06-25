//
//  SNESImageSource.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SSImageSource.h"

@interface SSWindowImageSource : SSImageSource

@property (readonly, getter=isPolling, nonatomic) BOOL polling;
@property (strong) NSDate *start;
@property double speedMultiplier;

-(BOOL)startPolling;
-(void)stopPolling;

-(CGWindowID)findSNESWindowId;

@end
