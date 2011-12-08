//
//  SSMainController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMainController.h"

@implementation SSMainController

@synthesize running=_running, currentRun=_run;

-(id)init
{
    if (self = [super init]) {
        _imageProcessor = [[SSImageProcessor alloc] init];
    }
    return self;
}

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

    // If we're just paused, we already have a run, and we just resume it.
    if (!_run) {
        _run = [[SSRun alloc] init];
        [_run startRoom];
    }
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
    _run = [[SSRun alloc] init];
}

-(NSURL *)runsDirectoryURL
{
    NSString *runsPath = @"~/Library/Application Support/Super Splits/";
    runsPath = [runsPath stringByExpandingTildeInPath];
    NSURL *runsURL = [NSURL fileURLWithPath:runsPath];
    [[NSFileManager defaultManager] createDirectoryAtURL:runsURL withIntermediateDirectories:YES attributes:nil error:nil];
    return runsURL;
}

-(NSURL *)urlForRun
{
    NSURL *runsDirectory = [self runsDirectoryURL];
    NSString *filename = [NSString stringWithFormat:@"Splits %s.csv", [[_run  startTime] description]];
    return [runsDirectory URLByAppendingPathComponent:filename];
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

// Used for debugging.
void saveCGImageToPath(CGImageRef image, NSString* path);
void saveCGImageToPath(CGImageRef image, NSString* path)
{
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
}

-(void)timerFired
{
    if (!_windowID)
        return;

    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, _windowID, kCGWindowImageBoundsIgnoreFraming | kCGWindowImageShouldBeOpaque);

    // Look for if the image is a transition screen.
    // If it's a transition screen, print room time and reset the room timer.
    if ([_imageProcessor isTransitionScreen:windowImage]) {
        if (![_run inTransition])
            [_run startTransition];
    } else {
        if ([_run inTransition])
            [_run endTransition];
    }

    CGImageRelease(windowImage);
}

@end
