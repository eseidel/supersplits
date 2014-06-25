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

@property (copy) NSString *entryMapState;
@property (copy) NSString *exitMapState;
@property NSTimeInterval offset;
@property NSTimeInterval duration;

@property (strong) SSMetroidFrame *entryFrame;
@property (strong) SSMetroidFrame *exitFrame;

@property (copy) NSString *roomName;

-(id)initWithString:(NSString *)archiveString;
-(NSString *)stringForArchiving;

@end
