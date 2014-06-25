//
//  SSMetroidFrame.h
//  Super Splits
//
//  Created by Eric Seidel on 12/10/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SSMetroidFrame : NSObject

@property (readonly, nonatomic) BOOL isMissingEnergyText;
@property (readonly, nonatomic) BOOL isItemScreen;
@property (readonly, nonatomic) BOOL isMostlyBlack;
@property (readonly, nonatomic) NSString *miniMapString;
@property (readonly, strong, nonatomic) NSImage *debugImage;
@property (readonly, strong, nonatomic) NSImage *originalImage;

-(id)initWithCGImage:(CGImageRef)image;

@end
