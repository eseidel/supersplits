//
//  SSSplit.h
//  Super Splits
//
//  Created by Eric Seidel on 12/13/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSMetroidFrame;

@interface SSSplit : NSObject

@property (retain) NSString *entryMapState;
@property (retain) NSString *exitMapState;
@property NSTimeInterval offset;
@property NSTimeInterval duration;

@property (retain) SSMetroidFrame *entryFrame;
@property (retain) SSMetroidFrame *exitFrame;

@property (retain) NSString *roomName;

-(id)initWithString:(NSString *)archiveString;
-(NSString *)stringForArchiving;

@end
