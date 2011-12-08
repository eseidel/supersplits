//
//  SSImageProcessor.h
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSImageProcessor : NSObject

-(CGPoint)findMapCenter:(CGImageRef)frame;
-(CGRect)findEnergyText:(CGImageRef)frame;
-(BOOL)isTransitionScreen:(CGImageRef)image;

@end
