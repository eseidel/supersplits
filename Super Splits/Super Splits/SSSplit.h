//
//  SSSplit.h
//  Super Splits
//
//  Created by Eric Seidel on 12/13/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSSplit : NSObject

@property (retain) NSString *entryMapState;
@property (retain) NSString *exitMapState;
@property (retain) NSNumber *duration;

-(id)initWithString:(NSString *)archiveString;
-(NSString *)stringForArchiving;

@end
