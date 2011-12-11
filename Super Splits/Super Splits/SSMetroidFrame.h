//
//  SSMetroidFrame.h
//  Super Splits
//
//  Created by Eric Seidel on 12/10/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSMetroidFrame : NSObject
{
    CGImageRef _image;
    CFDataRef _pixelData;

    CGRect _gameRectInImage;
    CGAffineTransform _fromGameRectToImage;
}

@property (readonly) BOOL isMissingEnergyText;
@property (readonly) BOOL isMostlyBlack;

-(id)initWithCGImage:(CGImageRef)image;

-(NSImage *)createDebugImage;

@end
