//
//  SSImageProcessor.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSImageProcessor : NSObject

-(NSImage *)createDebugImage:(CGImageRef)frame;

-(CGRect)findMiniMap:(CGImageRef)frame;
-(CGRect)findEnergyText:(CGImageRef)frame;
-(BOOL)isTransitionScreen:(CGImageRef)image;

@end
