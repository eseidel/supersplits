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

-(size_t)countPixelsInRect:(CGRect)rect aboveColor:(const uint8[4])lower belowColor:(const uint8[4])upper;

@end

const CGRect unitGameRect = { 0, 0, 512, 450};
const CGFloat statusLineVerticalOffset = 386;

@implementation SSMetroidFrame

-(id)initWithCGImage:(CGImageRef)image
{
    if (self = [super init]) {
        _image = image;
        if (![self isSupportedImage:image]) {
            NSLog(@"Unsupported image format!");
            return nil;
        }
        CFRetain(image);
        _pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image));

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
    CFRelease(_pixelData);
    CFRelease(_image);
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

-(size_t)countPixelsInRect:(CGRect)rect aboveColor:(const uint8[4])lowPixel belowColor:(const uint8[4])highPixel;
{
    const uint8 *pixels = CFDataGetBytePtr(_pixelData);

    size_t height = CGImageGetHeight(_image);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(_image);
    size_t bytesPerPixel = bitsPerPixel / 8;
    assert(bytesPerPixel == 4); // This function assumes 4-byte pixels.
    size_t bytesPerRow = CGImageGetBytesPerRow(_image);
    
    // FIXME: It appears this assertion fails if you resize the window?
    assert(bytesPerPixel * CGImageGetWidth(_image) == bytesPerRow);
    
    size_t matchingPixelCount = 0;
    
    // Careful to flip from CG coordinates to offsets into the pixel buffer.
    size_t minX = rect.origin.x;
    size_t minY = height - CGRectGetMaxY(rect);
    size_t maxX = CGRectGetMaxX(rect);
    size_t maxY = height - rect.origin.y;

    for (size_t y = minY; y < maxY; y++) {
        for (size_t x = minX; x < maxX; x++) {
            const uint8 *pixel = pixels + y * bytesPerRow + x * bytesPerPixel;
            // kCGImageAlphaNoneSkipFirst means skip the highest order byte, aka pixel[3] on little endian.
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
    // match how countPixelsInRect works. 
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
    NSImage *image = [[NSImage alloc] init];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:newImage];
    [image addRepresentation:bitmapRep];
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

    const uint8 lowPixel[4] = {180, 180, 180, 0};
    const uint8 highPixel[4] =  {255, 255, 255, 255};
    size_t whitePixelCount = [self countPixelsInRect:energyTextRect aboveColor:lowPixel belowColor:highPixel];

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
    const uint8 lowPixel[4] = {0, 0, 0, 0};
    const uint8 highPixel[4] =  {5, 5, 5, 255};
    CGRect mainRect = [self _findMainRect];
    size_t blackPixelCount = [self countPixelsInRect:mainRect aboveColor:lowPixel belowColor:highPixel];

    const float percentBlackTransitionThreshold = 0.87f;
    size_t totalPixelCount = mainRect.size.height * mainRect.size.width;
    return blackPixelCount > (size_t)((float)totalPixelCount * percentBlackTransitionThreshold);
}

-(NSImage *)createDebugImage
{
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:_image];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];

    [image lockFocus];
    [[[NSColor blueColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findGameRect]];

    [[[NSColor orangeColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findMainRect]];

    [[[NSColor whiteColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findEnergyText]];

    [[[NSColor greenColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self _findMiniMap]];
    [image unlockFocus];

    return image;
}

@end
