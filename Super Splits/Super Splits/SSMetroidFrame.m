//
//  SSMetroidFrame.m
//  Super Splits
//
//  Created by Eric Seidel on 12/10/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMetroidFrame.h"

@interface SSMetroidFrame (PrivateMethods)

-(BOOL)isSupportedImage:(CGImageRef)frame;

-(CGRect)_findGameRect;
-(CGRect)_findMiniMap;
-(CGRect)_findEnergyText;

-(size_t)_countPixelsInRect:(CGRect)rect aboveRGB:(const uint8[3])lowRGB belowRGB:(const uint8[3])highRGB;

@end

const CGRect unitGameRect = { 0, 0, 512, 450};
const CGFloat statusLineVerticalOffset = 386;

@implementation SSMetroidFrame

@synthesize debugImage=_debugImage;

-(id)initWithCGImage:(CGImageRef)image
{
    if (self = [super init]) {
        _image = image;
        if (![self isSupportedImage:image]) {
            NSLog(@"Unsupported image format!");
            _image = nil;
            return nil;
        }
        CGImageRetain(image);
        _pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image));
        if (!_pixelData) {
            NSLog(@"Failed to get pixel data from image!");
            return nil;
        }
        _gameRectInImage = [self _findGameRect];
        if (CGRectEqualToRect(_gameRectInImage, CGRectZero)) {
            NSLog(@"Failed to find game rect!");
            return nil;
        }
        // All our measurments are based off of Snes9x at the default scale.
        _fromGameRectToImage = CGAffineTransformMakeTranslation(_gameRectInImage.origin.x, _gameRectInImage.origin.y);
        _fromGameRectToImage = CGAffineTransformScale(_fromGameRectToImage,
                                                      _gameRectInImage.size.width / unitGameRect.size.width,
                                                      _gameRectInImage.size.height / unitGameRect.size.height);
    }
    return self;
}

-(void)dealloc
{
    if (_pixelData) {
        CFRelease(_pixelData);
    }
    CGImageRelease(_image);
}

-(CGRect)_findGameRect
{
    const CGFloat titleBarHeight = 22.0; // 22px tall in lion.
    // FIXME: This is a big hack and only works for the default emulator size.
    if (CGImageGetWidth(_image) == 512 && CGImageGetHeight(_image) == 500) {
        const CGFloat verticalPadding = 14.0; // Snes9x default window size pads 14px black on the top/bottom.
        return CGRectMake(0, verticalPadding, 512, 500 - 2 * verticalPadding - titleBarHeight);
    } else if (CGImageGetWidth(_image) == 320 && CGImageGetHeight(_image) == 290) {
        const CGFloat vlcControlsHeight = 29.0;
        const CGFloat verticalPadding = 7.0;
        const CGFloat horizontalPadding = 30.0; // Twitch.tv aspect ratio is different from SNES.
        return CGRectMake(horizontalPadding, vlcControlsHeight + verticalPadding, 320 - 2 * horizontalPadding, 290 - titleBarHeight - vlcControlsHeight - 2 * verticalPadding);
    }
    return CGRectZero;
}

-(CGRect)_findMainRect
{
    CGRect mainRect = { 0, 0, unitGameRect.size.width, statusLineVerticalOffset };
    return CGRectApplyAffineTransform(mainRect, _fromGameRectToImage);
}

-(CGRect)_findMiniMap
{
    // The map is at 417, 35 (on a 512 x 450 game rect) and is 82 x 48.
    CGPoint mapOrigin = CGPointMake(416, statusLineVerticalOffset);
    CGSize mapSize = { 84, 52 };
    CGRect mapRect = { mapOrigin, mapSize };
    return CGRectApplyAffineTransform(mapRect, _fromGameRectToImage);
}

-(CGRect)_findEnergyText
{
    CGPoint textOrigin = CGPointMake(15, statusLineVerticalOffset + 2);
    CGSize textSize = { 113, 14 };
    CGRect textRect = { textOrigin, textSize };
    return CGRectApplyAffineTransform(textRect, _fromGameRectToImage);
}

-(size_t)_countPixelsInRect:(CGRect)rect aboveRGB:(const uint8[3])lowRGB belowRGB:(const uint8[3])highRGB;
{
    const uint8 *pixels = CFDataGetBytePtr(_pixelData);

    size_t height = CGImageGetHeight(_image);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(_image);
    size_t bytesPerPixel = bitsPerPixel / 8;
    assert(bytesPerPixel == 4); // This function assumes 4-byte pixels.
    size_t bytesPerRow = CGImageGetBytesPerRow(_image);

    // FIXME: It appears this assertion fails if you resize the window?
    assert(bytesPerPixel * CGImageGetWidth(_image) == bytesPerRow);

    // This matches kCGImageAlphaNoneSkipFirst on little endian.
    // kCGImageAlphaNoneSkipFirst means skip the highest order byte, aka pixel[3] on little endian.
    uint8 lowPixel[4] = { lowRGB[0], lowRGB[1], lowRGB[2], 0 };
    uint8 highPixel[4] = { highRGB[0], highRGB[1], highRGB[2], 255 };

    // Careful to flip from CG coordinates to offsets into the pixel buffer.
    size_t minX = rect.origin.x;
    size_t minY = height - CGRectGetMaxY(rect);
    size_t maxX = CGRectGetMaxX(rect);
    size_t maxY = height - rect.origin.y;

    size_t matchingPixelCount = 0;
    for (size_t y = minY; y < maxY; y++) {
        for (size_t x = minX; x < maxX; x++) {
            const uint8 *pixel = pixels + y * bytesPerRow + x * bytesPerPixel;
            if (pixel[0] >= lowPixel[0] && pixel[0] <= highPixel[0]
                && pixel[1] >= lowPixel[1] && pixel[1] <= highPixel[1]
                && pixel[2] >= lowPixel[2] && pixel[2] <= highPixel[2]
                && pixel[3] >= lowPixel[3] && pixel[3] <= highPixel[3])
                matchingPixelCount++;
        }
    }

    return matchingPixelCount;
}

// This method is for debugging.
-(NSImage *)subimageForRect:(CGRect)rect
{
    // We're using a less-efficent pixel-copying method in order to
    // match how _countPixelsInRect works.
    const uint8 *pixels = CFDataGetBytePtr(_pixelData);
    
    size_t height = CGImageGetHeight(_image);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(_image);
    size_t bytesPerPixel = bitsPerPixel / 8;
    assert(bytesPerPixel == 4); // This function assumes 4-byte pixels.
    size_t bytesPerRow = CGImageGetBytesPerRow(_image);
    
    // FIXME: It appears this assertion fails if you resize the window?
    assert(bytesPerPixel * CGImageGetWidth(_image) == bytesPerRow);
    
    // Careful to flip from CG coordinates to offsets into the pixel buffer.
    size_t minX = rect.origin.x;
    size_t minY = height - CGRectGetMaxY(rect);
    size_t maxX = CGRectGetMaxX(rect);
    size_t maxY = height - rect.origin.y;

    CGContextRef context = CGBitmapContextCreate(NULL,
                                               rect.size.width,
                                               rect.size.height,
                                               CGImageGetBitsPerComponent(_image),
                                               bytesPerRow,  // FIXME: Unclear why this value is correct.
                                               CGImageGetColorSpace(_image),
                                               CGImageGetBitmapInfo(_image));

    uint8 *newPixels = CGBitmapContextGetData(context);
    for (size_t y = minY; y < maxY; y++) {
        for (size_t x = minX; x < maxX; x++) {
            const uint8 *pixel = pixels + y * bytesPerRow + x * bytesPerPixel;
            uint8* newPixel = newPixels + (y - minY) * bytesPerRow + (x - minX) * bytesPerPixel;
            newPixel[0] = pixel[0];
            newPixel[1] = pixel[1];
            newPixel[2] = pixel[2];
            newPixel[3] = pixel[3];
        }
    }
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    NSImage *image = [[NSImage alloc] init];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:newImage];
    [image addRepresentation:bitmapRep];
    CGImageRelease(newImage);
    return image;
}

-(BOOL)isSupportedImage:(CGImageRef)frame
{
    CGImageAlphaInfo info = CGImageGetAlphaInfo(frame);
    if (info != kCGImageAlphaNoneSkipFirst) {
        static BOOL haveLogged = NO;
        if (!haveLogged) {
            NSLog(@"Wrong alpha info?  Target window is likely off-screen? (got: %d, expected: %d)", info, kCGImageAlphaNoneSkipFirst);
            haveLogged = YES;
        }
        return NO;
    }
    return YES;
}

-(BOOL)isMissingEnergyText
{
    CGRect energyTextRect = [self _findEnergyText];
    if (CGRectEqualToRect(energyTextRect, CGRectZero)) {
        NSLog(@"Failed to find energy rect!");
        return NO;  // We don't know, so assume not.
    }

    const uint8 lowRGB[3] = {180, 180, 180};
    const uint8 highRGB[3] =  {255, 255, 255};
    size_t whitePixelCount = [self _countPixelsInRect:energyTextRect aboveRGB:lowRGB belowRGB:highRGB];

    // The Energy text is white, but few of the pixels are actually fully white.
    // If more than 15% of our pixels white, assume it's the energy text.
    // Currently this is set very low, as with antialiasing, we end up with very few "white"
    // pixels when rendering the screen at a small size.
    const float percentWhiteEnergyThreshold = 0.05f;
    size_t totalPixelCount = energyTextRect.size.width * energyTextRect.size.height;
    return whitePixelCount < (size_t)((float)totalPixelCount * percentWhiteEnergyThreshold);
}

-(BOOL)isMostlyBlack
{
    const uint8 lowRGB[3] = {0, 0, 0};
    const uint8 highRGB[3] =  {5, 5, 5};
    CGRect mainRect = [self _findMainRect];
    size_t blackPixelCount = [self _countPixelsInRect:mainRect aboveRGB:lowRGB belowRGB:highRGB];

    const float percentBlackTransitionThreshold = 0.87f;
    size_t totalPixelCount = mainRect.size.height * mainRect.size.width;
    return blackPixelCount > (size_t)((float)totalPixelCount * percentBlackTransitionThreshold);
}

-(CGRect)_findUpperItemTextRect
{
    CGPoint textOrigin = CGPointMake(205, 210);
    CGSize textSize = { 113, 16 }; // Just wide enough to hold "MISSLE"
    CGRect textRect = { textOrigin, textSize };
    return CGRectApplyAffineTransform(textRect, _fromGameRectToImage);
}

-(CGRect)_findLowerItemTextRect
{
    CGPoint textOrigin = CGPointMake(205, 193);
    CGSize textSize = { 113, 16 };
    CGRect textRect = { textOrigin, textSize };
    return CGRectApplyAffineTransform(textRect, _fromGameRectToImage);
}

-(BOOL)isItemScreen
{
    // The pink is about 194, 90, 142, using +/-20 for now.
    const uint8 lowRGB[3] = {120, 70, 170};
    const uint8 highRGB[3] =  {160, 110, 210};

    CGRect itemRect = [self _findLowerItemTextRect];
    size_t pinkPixelCount = [self _countPixelsInRect:itemRect aboveRGB:lowRGB belowRGB:highRGB];
    // FIXME: 3% is a very poor indicator, we need to handle antialiasing better!
    const float percentPinkItemThreshold = 0.03f;
    size_t totalPixelCount = itemRect.size.height * itemRect.size.width;
    if (pinkPixelCount > (size_t)((float)totalPixelCount * percentPinkItemThreshold))
        return YES;

    itemRect = [self _findUpperItemTextRect];
    pinkPixelCount = [self _countPixelsInRect:itemRect aboveRGB:lowRGB belowRGB:highRGB];
    totalPixelCount = itemRect.size.height * itemRect.size.width;
    return pinkPixelCount > (size_t)((float)totalPixelCount * percentPinkItemThreshold);
}

-(NSString *)miniMapString
{
    const uint8 lowRGB[3] = {0, 0, 0};
    // We're very flexible about what we call "black" to avoid false positives from antialiasing.
    const uint8 highRGB[3] =  {25, 25, 25};

    NSMutableString *mapString = [NSMutableString string];
    
    CGRect mapRect = [self _findMiniMap];
    // The map is 5 x 3.
    CGSize mapSquare = { mapRect.size.width / 5.0, mapRect.size.height / 3.0 };
    for (size_t y = 0; y < 3; y++) {
        for (size_t x = 0; x < 5; x++) {
            CGRect rect = { mapRect.origin.x + mapSquare.width * x,
                            mapRect.origin.y + mapSquare.height * y,
                            mapSquare.width, mapSquare.height };
            size_t blackPixelCount = [self _countPixelsInRect:rect aboveRGB:lowRGB belowRGB:highRGB];

            // 30% black is enough to signify an empty square.
            // At small frame sizes the border dominates the square, and 40% is slightly too agressive.
            // We could also inset the square by some percent and use a more agressive percent black.
            const float emptyMapSquareThreshold = 0.30f;
            size_t totalPixelCount = rect.size.width * rect.size.height;
            bool isEmpty = blackPixelCount > (size_t)((float)totalPixelCount * emptyMapSquareThreshold);
            [mapString appendString:(isEmpty ? @"0" : @"1")];
        }
        if (y < 2)
            [mapString appendString:@", "];
    }
    return mapString;
}

-(NSImage *)debugImage
{
    if (_debugImage)
        return _debugImage;

    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:_image];
    _debugImage = [[NSImage alloc] init];
    [_debugImage addRepresentation:bitmapRep];

    [_debugImage lockFocus];
    [[[NSColor blueColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findGameRect]];

    [[[NSColor orangeColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findMainRect]];

    [[[NSColor whiteColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findEnergyText]];

    [[[NSColor greenColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findMiniMap]];
    
    [[[NSColor yellowColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findUpperItemTextRect]];

    [[[NSColor yellowColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findLowerItemTextRect]];
    [_debugImage unlockFocus];

    return _debugImage;
}

@end
