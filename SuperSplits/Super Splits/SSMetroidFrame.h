//
//  SSMetroidFrame.h
//  Super Splits
//
//  Created by Eric Seidel on 12/10/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SSMetroidFrame : NSObject
{
    CGImageRef _image;
    CFDataRef _pixelData;

    CGRect _gameRectInImage;
    CGAffineTransform _fromGameRectToImage;
}

@property (readonly) BOOL isMissingEnergyText;
@property (readonly) BOOL isItemScreen;
@property (readonly) BOOL isMostlyBlack;
@property (readonly) NSString *miniMapString;
@property (readonly, retain) NSImage *debugImage;
@property (readonly, retain) NSImage *originalImage;

-(id)initWithCGImage:(CGImageRef)image;

@end
