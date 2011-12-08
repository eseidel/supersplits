//
//  SSImageProcessor.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSImageProcessor.h"

@implementation SSImageProcessor

-(CGRect)findMiniMap:(CGImageRef)frame
{
    // FIXME: This is a big hack and only works for the default emulator size.
    if (CGImageGetWidth(frame) != 512 || CGImageGetHeight(frame) != 500)
        return CGRectZero;

    const CGFloat contentBottomPadding = 14.0; // SNES98x pads 14px black on the top/bottom.
    // Thus the window is 512x500 = 512x(500 - 22 - 14 - 14) = 512x450 (title bar is 22px).
    // The map is at 417, 35 (on a 512 x 478 window) and is 82 x 48.
    CGPoint mapOrigin = { 416, 387 };
    CGSize mapSize = { 84, 52 };
    CGRect mapRect = { mapOrigin, mapSize };
    return CGRectOffset(mapRect, 0.0, contentBottomPadding);
}

-(CGRect)findEnergyText:(CGImageRef)frame
{
    // FIXME: This is a big hack and only works for the default emulator size.
    if (CGImageGetWidth(frame) != 512 || CGImageGetHeight(frame) != 500)
        return CGRectZero;
    
    const CGFloat contentBottomPadding = 14.0; // SNES98x pads 14px black on the top/bottom.
    // Thus the window is 512x500 = 512x(500 - 22 - 14 - 14) = 512x450 (title bar is 22px).
    CGPoint textOrigin = { 15, 387 };
    CGSize textSize = { 115, 18 };
    CGRect textRect = { textOrigin, textSize };
    return CGRectOffset(textRect, 0.0, contentBottomPadding);
}

size_t countMatchingPixelsInRect(CGImageRef frame, CFDataRef pixelData, CGRect rect, const uint8 lowPixel[4], const uint8 highPixel[4]);
size_t countMatchingPixelsInRect(CGImageRef frame, CFDataRef pixelData, CGRect rect, const uint8 lowPixel[4], const uint8 highPixel[4])
{
    const uint8 *pixels = CFDataGetBytePtr(pixelData);

    size_t height = CGImageGetHeight(frame);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(frame);
    size_t bytesPerPixel = bitsPerPixel / 8;
    assert(bytesPerPixel == 4); // This function assumes 4-byte pixels.
    size_t bytesPerRow = CGImageGetBytesPerRow(frame);

    // FIXME: It appears this assertion fails if you resize the window?
    assert(bytesPerPixel * CGImageGetWidth(frame) == bytesPerRow);

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

-(BOOL)frameIsMissingEnergyText:(CGImageRef)frame withPixelData:(CFDataRef)pixelData
{
    CGRect energyTextRect = [self findEnergyText:frame];
    if (CGRectEqualToRect(energyTextRect, CGRectZero))
        return NO;  // We don't know, so assume not.

    const uint8 lowPixel[4] = {200, 200, 200, 0};
    const uint8 highPixel[4] =  {255, 255, 255, 255};
    size_t whitePixelCount = countMatchingPixelsInRect(frame, pixelData, energyTextRect, lowPixel, highPixel);
    
    // The Energy text is white, but few of the pixels are actually fully white.
    // If more than 15% of our pixels white, assume it's the energy text.
    const float percentWhiteEnergyThreshold = 0.15f;
    size_t totalPixelCount = energyTextRect.size.width * energyTextRect.size.height;
    return whitePixelCount < (size_t)((float)totalPixelCount * percentWhiteEnergyThreshold);
}

-(BOOL)frameIsMostlyBlack:(CGImageRef)frame withPixelData:(CFDataRef)pixelData
{
    const uint8 lowPixel[4] = {0, 0, 0, 0};
    const uint8 highPixel[4] =  {5, 5, 5, 255};
    CGRect fullRect = CGRectMake(0, 0, CGImageGetWidth(frame), CGImageGetHeight(frame));
    size_t blackPixelCount = countMatchingPixelsInRect(frame, pixelData, fullRect, lowPixel, highPixel);
    
    const float percentBlackTransitionThreshold = 0.8f;
    size_t totalPixelCount = fullRect.size.height * fullRect.size.width;
    return blackPixelCount > (size_t)((float)totalPixelCount * percentBlackTransitionThreshold);
}

-(BOOL)isTransitionScreen:(CGImageRef)frame
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(frame));

    if ([self frameIsMissingEnergyText:frame withPixelData:pixelData]) {
        CFRelease(pixelData);
        return YES;
    }

    BOOL mostlyBlack = [self frameIsMostlyBlack:frame withPixelData:pixelData];
    CFRelease(pixelData);
    return mostlyBlack;
}

-(NSImage *)createDebugImage:(CGImageRef)frame
{
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:frame];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];

    [image lockFocus];
    [[[NSColor whiteColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self findEnergyText:frame]];
    [image unlockFocus];

    [image lockFocus];
    [[[NSColor greenColor] colorWithAlphaComponent:.5] setFill];
    [NSBezierPath fillRect:[self findMiniMap:frame]];
    [image unlockFocus];

    return image;
}

@end
