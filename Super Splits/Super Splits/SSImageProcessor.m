//
//  SSImageProcessor.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSImageProcessor.h"

@implementation SSImageProcessor

-(CGPoint)findMapCenter:(CGImageRef)frame
{
    // FIXME: This is a big hack and only works for the default emulator size.
    if (CGImageGetWidth(frame) != 512 || CGImageGetHeight(frame) != 500)
        return CGPointZero;
    
    const CGFloat titleBarHeight = 22.0;
    const CGFloat contentTopPadding = 14.0; // SNES98x pads 14px on the top.
    // 14px of padding at the bottom on SNES98x.
    // Thus the window is 512x500 = 512x(500 - 22 - 14 - 14) = 512x450.
    // The map is at 417, 35 (on a 512 x 478 window) and is 82 x 48.
    CGPoint mapOrigin = { 417, 21 };
    CGSize mapSize = { 82, 48 };
    CGPoint mapCenter = { mapOrigin.x + mapSize.width / 2, mapOrigin.y + mapSize.height / 2 };
    return CGPointMake(mapCenter.x, mapCenter.y + titleBarHeight + contentTopPadding);
}

-(CGRect)findEnergyText:(CGImageRef)frame
{
    // FIXME: This is a big hack and only works for the default emulator size.
    if (CGImageGetWidth(frame) != 512 || CGImageGetHeight(frame) != 500)
        return CGRectZero;
    
    const CGFloat contentBottmPadding = 14.0; // SNES98x pads 14px on the top.
    // 14px of padding at the bottom on SNES98x.
    // Thus the window is 512x500 = 512x(500 - 22 - 14 - 14) = 512x450.
    CGPoint textOrigin = { 15, 387 };
    CGSize textSize = { 115, 18 };
    CGRect textRect = { textOrigin, textSize };
    return CGRectOffset(textRect, 0.0, contentBottmPadding);
}

-(BOOL)isTransitionScreen:(CGImageRef)frame
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(frame));
    const uint8 *pixels = CFDataGetBytePtr(pixelData);
    
    size_t height = CGImageGetHeight(frame);
    size_t width = CGImageGetWidth(frame);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(frame);
    size_t bytesPerPixel = bitsPerPixel / 8;
    size_t bytesPerRow = CGImageGetBytesPerRow(frame);
    
    // FIXME: It appears this assertion fails if you resize the window?
    assert(bytesPerPixel * width == bytesPerRow);

    CGImageAlphaInfo info = CGImageGetAlphaInfo(frame);

    // FIXME: We would like to assert(CGImageGetAlphaInfo(frame) == kCGImageAlphaNoneSkipFirst)
    // but we hit that assert if the user changes spaces.  So for now we just log once
    // and ignore the window while its off screen.  I'd like to find a better way to test
    // if the window is offscreen before calling this function so we can assert!
    if (info != kCGImageAlphaNoneSkipFirst) {
        static BOOL haveLogged = NO;
        if (!haveLogged) {
            NSLog(@"Wrong alpha info?  Target window is likely off-screen? (got: %d, expected: %d)", info, kCGImageAlphaNoneSkipFirst);
            haveLogged = YES;
        }
        // We don't know anything about the window if it's offscreen?
        CFRelease(pixelData);
        return NO;
    }

// FIXME: This works, except when fighting ridley the first time the map is an empty grid.
//    CGPoint mapCenter = [self findMapCenter:frame];
//    if (!CGPointEqualToPoint(mapCenter, CGPointZero)) {
//        const uint8 *pixel = pixels + (int)mapCenter.y * bytesPerRow + (int)mapCenter.x * bytesPerPixel;
//        // If the center of the map is black, this must be a cut-scene!
//        if (pixel[0] < 5 && pixel[1] < 5 && pixel[2] < 5) {
//            return YES;
//        }
//    }

    CGRect energyTextRect = [self findEnergyText:frame];
    if (!CGRectEqualToRect(energyTextRect, CGRectZero)) {
        unsigned whitePixelCount = 0;

        // Careful to flip from CG coordinates to offsets into the pixel buffer.
        size_t minX = energyTextRect.origin.x;
        size_t minY = height - CGRectGetMaxY(energyTextRect);
        size_t maxX = CGRectGetMaxX(energyTextRect);
        size_t maxY = height - energyTextRect.origin.y;

        for (size_t y = minY; y < maxY; y++) {
            for (size_t x = minX; x < maxX; x++) {
                const uint8 *pixel = pixels + y * bytesPerRow + x * bytesPerPixel;
                // kCGImageAlphaNoneSkipFirst means skip the highest order byte, aka pixel[3] on little endian.
                if (pixel[0] > 200 && pixel[1] > 200 && pixel[2] > 200)
                    whitePixelCount++;
            }
        }
        size_t totalPixelCount = energyTextRect.size.width * energyTextRect.size.height;

        // The Energy text is white, but few of the pixels are actually fully white.
        // If more than 15% of our pixels white, assume it's the energy text.
        const float percentWhiteEnergyThreshold = 0.15f;
        if (whitePixelCount < (size_t)((float)totalPixelCount * percentWhiteEnergyThreshold)) {
            CFRelease(pixelData);
            return YES;
        }
    }

    size_t totalPixelCount = height * width;
    unsigned blackPixelCount = 0;
    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            const uint8 *pixel = pixels + y * bytesPerRow + x * bytesPerPixel;
            // kCGImageAlphaNoneSkipFirst means skip the highest order byte, aka pixel[3] on little endian.
            if (pixel[0] < 5 && pixel[1] < 5 && pixel[2] < 5)
                blackPixelCount++;
        }
    }
    //    NSLog(@"Black pixels: %u, total: %lu", blackPixelCount, totalPixelCount);
    CFRelease(pixelData);
    
    const float percentBlackTransitionThreshold = 0.8f;
    return blackPixelCount > (size_t)((float)totalPixelCount * percentBlackTransitionThreshold);
}

-(NSImage *)createDebugImage:(CGImageRef)frame
{
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:frame];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];

    CGRect energyTextRect = [self findEnergyText:frame];

    [image lockFocus];
    NSColor *color = [[NSColor whiteColor] colorWithAlphaComponent:.5];
    [color setFill];
    [NSBezierPath fillRect:energyTextRect];
    [image unlockFocus];

    return image;
}

@end
