//
//  SSMainController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMainController.h"

@implementation SSMainController

@synthesize running=_running;

-(void)startRun
{
    assert(!_running);
    _windowID = [self findSNESWindowId];
    _running = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / 30.0f)
                                              target:self
                                            selector:@selector(timerFired)
                                            userInfo:self
                                             repeats:true];

    // This is a way of detecting if we're paused.
    if (!_overallStart) {
        _overallStart = [NSDate date];
        _roomStart = nil;
        _transitionStart = nil;
        _roomSplits = [NSMutableArray array];
    }
    [self startRoom];
}

-(void)stopRun
{
    assert(_running);
    [_timer invalidate];
    _timer = nil;
    _running = NO;
    _windowID = kCGNullWindowID; // This isn't strictly necessary.
}

-(void)resetRun
{
    _overallStart = nil;
    _roomStart = nil;
    _transitionStart = nil;
    _roomSplits = nil;
}

-(NSURL *)runsDirectoryURL
{
    NSString *runsPath = @"~/Library/Application Support/Super Splits/";
    runsPath = [runsPath stringByExpandingTildeInPath];
    NSURL *runsURL = [NSURL fileURLWithPath:runsPath];
    [[NSFileManager defaultManager] createDirectoryAtURL:runsURL withIntermediateDirectories:YES attributes:nil error:nil];
    return runsURL;
}

-(NSURL *)urlForCurrentRun
{
    NSURL *runsDirectory = [self runsDirectoryURL];
    NSString *filename = [NSString stringWithFormat:@"Splits %s.csv", [_overallStart description]];
    return [runsDirectory URLByAppendingPathComponent:filename];
}

-(void)saveSplits
{
    NSURL* runFile = [self urlForCurrentRun];
    NSMutableString *splitsString = [[NSMutableString alloc] init];
    for (NSNumber *splitTime in _roomSplits) {
        [splitsString appendFormat:@"%.2f", [splitTime doubleValue]];
    }
    [splitsString writeToURL:runFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

NSString *kAppNameKey = @"applicationName";	// Application Name & PID
NSString *kWindowIDKey = @"windowID"; // Window ID

void SNESWindowSearchFunction(const void *inputDictionary, void *context);
void SNESWindowSearchFunction(const void *inputDictionary, void *context)
{
	NSDictionary *entry = (__bridge NSDictionary*)inputDictionary;
	CGWindowID *snesWindowId = (CGWindowID*)context;
    CGWindowID windowId = [[entry objectForKey:(id)kCGWindowNumber] unsignedIntValue];

    // Grab the application name, but since it's optional we need to check before we can use it.
    NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
    if (![applicationName isEqualToString:@"Snes9x"]) {
        //NSLog(@"Ignoring: %d, wrong app.", windowId);
        return;
    }

    CGRect bounds;
    CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);
    if (bounds.size.width < 200 || bounds.size.height < 200) {
        //NSLog(@"Ignoring: %d, too small.", windowId);
        return;
    }

    *snesWindowId = windowId;
    NSLog(@"Found window with size: %f x %f, %d", bounds.size.width, bounds.size.height, windowId);
}

-(CGWindowID)findSNESWindowId
{
	// Ask the window server for the list of windows.
	CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);

	CGWindowID snesWindowId = kCGNullWindowID;
	CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &SNESWindowSearchFunction, &snesWindowId);
	CFRelease(windowList);

    return snesWindowId;
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

    assert(bytesPerPixel * width == bytesPerRow);
    // FIXME: We hit this assert when the user changes spaces!
    assert(kCGImageAlphaNoneSkipFirst == CGImageGetAlphaInfo(frame));

    unsigned blackPixelCount = 0;
    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            const uint8 *pixel = pixels + y * bytesPerRow + x * bytesPerPixel;
//            if (y == 100)
//                NSLog(@"%d,%d: %d %d %d %d", x, y, pixel[0], pixel[1], pixel[2], pixel[3]);
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

-(void)startRoom
{
    if (_transitionStart) {
        NSNumber *roomSplit = [self roomTime];
        [_roomSplits addObject:roomSplit];
        NSLog(@"Room split: %.2fs", [roomSplit doubleValue]);
    }
    _roomStart = [NSDate date];
    _transitionStart = nil;
}

-(BOOL)inTransition
{
    return (BOOL)_transitionStart;
}

-(void)startTransition
{
    assert(![self inTransition]);
    _transitionStart = [NSDate date];
}

-(void)endTransition
{
    assert([self inTransition]);
    [self startRoom];
}

-(NSNumber *)lastRoomSplit
{
    return [_roomSplits lastObject];
}

-(NSNumber *)roomTime
{
    NSTimeInterval roomTime;
    if ([self inTransition])
        roomTime = [_transitionStart timeIntervalSinceDate:_roomStart];
    else
        roomTime = -[_roomStart timeIntervalSinceNow];
    return [NSNumber numberWithDouble:roomTime];
}

-(NSNumber *)totalTime
{
    return [NSNumber numberWithDouble:-[_overallStart timeIntervalSinceNow]];
}

-(void)timerFired
{
    if (!_windowID)
        return;

    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, _windowID, kCGWindowImageBoundsIgnoreFraming | kCGWindowImageShouldBeOpaque);

    // Look for if the image is a transition screen.
    // If it's a transition screen, print room time and reset the room timer.
    if ([self isTransitionScreen:windowImage]) {
        if (![self inTransition])
            [self startTransition];
    } else {
        if ([self inTransition])
            [self endTransition];
    }

    CGImageRelease(windowImage);
}

@end
