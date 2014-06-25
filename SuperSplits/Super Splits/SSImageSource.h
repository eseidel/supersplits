//
//  SSImageSource.h
//  Super Splits
//
//  Created by Eric Seidel on 12/18/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSImageSourceDelegate
-(void)nextFrame:(CGImageRef)frame atOffset:(NSTimeInterval)offset;
@end


@interface SSImageSource : NSObject

@property (weak) id<SSImageSourceDelegate> delegate;

@end
