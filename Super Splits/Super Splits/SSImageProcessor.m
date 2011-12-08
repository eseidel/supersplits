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
    
    const CGFloat titleBarHeight = 22.0;
    const CGFloat contentTopPadding = 14.0; // SNES98x pads 14px on the top.
    // 14px of padding at the bottom on SNES98x.
    // Thus the window is 512x500 = 512x(500 - 22 - 14 - 14) = 512x450.
    CGPoint textOrigin = { 0, 40 };
    CGSize textSize = { 130, 20 };
    CGRect textRect = { textOrigin, textSize };
    return CGRectOffset(textRect, 0.0, titleBarHeight + contentTopPadding);
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
    
    //    CGRect energyTextRect = [self findEnergyText:frame];
    //    if (!CGRectEqualToRect(energyTextRect, CGRectZero)) {
    //        unsigned whitePixelCount = 0;
    //        for (size_t y = energyTextRect.origin.y; y < energyTextRect.size.height; y++) {
    //            for (size_t x = energyTextRect.origin.x; x < energyTextRect.size.width; x++) {
    //                const uint8 *pixel = pixels + y * bytesPerRow + x * bytesPerPixel;
    //                // It appears that despite this being "skip first" it's the last we should skip?
    //                if (pixel[0] > 230 && pixel[1] > 230 && pixel[2] > 230)
    //                    whitePixelCount++;
    //            }
    //        }
    //        size_t totalPixelCount = energyTextRect.size.width * energyTextRect.size.height;
    //
    //        const float percentWhiteEnergyThreshold = 0.5f;
    //        if (whitePixelCount < (size_t)((float)totalPixelCount * percentWhiteEnergyThreshold)) {
    //            CFRelease(pixelData);
    //            NSLog(@"No energy!");
    //            return YES;
    //        }
    //    }
    
    unsigned blackPixelCount = 0;
    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            const uint8 *pixel = pixels + y * bytesPerRow + x * bytesPerPixel;
            // It appears that despite this being "skip first" it's the last we should skip?
            if (pixel[0] < 5 && pixel[1] < 5 && pixel[2] < 5)
                blackPixelCount++;
        }
    }
    size_t totalPixelCount = height * width;
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
    return image;
}

@end
