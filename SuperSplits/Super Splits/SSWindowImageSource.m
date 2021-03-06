//
//  SNESImageSource.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSWindowImageSource.h"
#import "SSUserDefaults.h"

@implementation SSWindowImageSource
{
    CGWindowID _windowID;
	NSTimer *_timer;

    double _speedMultiplier;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self bind:@"speedMultiplier"
          toObject:[NSUserDefaultsController sharedUserDefaultsController]
       withKeyPath:[@"values." stringByAppendingString:kSpeedMultiplierDefaultName]
           options:nil];
    }
    return self;
}

-(void)dealloc
{
    [self unbind:@"speedMultiplier"];
}

-(BOOL)startPolling
{
    assert(!_timer);
    _windowID = [self findSNESWindowId];
    if (!_windowID) {
        NSLog(@"Failed to find window! Not starting.");
        return NO;
    }

    // FIXME: Should this use a max?
    double scansPerSecond = 10.0 * _speedMultiplier;
    NSTimeInterval interval = (1.0 / scansPerSecond);

    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(timerFired)
                                            userInfo:self
                                             repeats:true];
    if (!_start)
        _start = [NSDate date];
    return YES;
}

-(BOOL)isPolling
{
    return !!_timer;
}

-(void)stopPolling
{
    assert(_timer);
    [_timer invalidate];
    _timer = nil;
    _windowID = kCGNullWindowID;
    // Note: Currently not clearing start.  Unclear how "pause" should function.
}

void WindowSearchFunction(const void *inputDictionary, void *context);
void WindowSearchFunction(const void *inputDictionary, void *context)
{
    NSString *targetApplicationName = @"Snes9x";
    //NSString *targetApplicationName = @"VLC";
	NSDictionary *entry = (__bridge NSDictionary*)inputDictionary;
	CGWindowID *foundWindowId = (CGWindowID*)context;
    CGWindowID windowId = [entry[(id)kCGWindowNumber] unsignedIntValue];
    
    // Grab the application name, but since it's optional we need to check before we can use it.
    NSString *applicationName = entry[(id)kCGWindowOwnerName];
    if (![applicationName isEqualToString:targetApplicationName]) {
        //NSLog(@"Ignoring: %d, wrong app.", windowId);
        return;
    }

    CGRect bounds;
    CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)entry[(id)kCGWindowBounds], &bounds);
    if (bounds.size.width < 250 || bounds.size.height < 250) {
        //NSLog(@"Ignoring: %d, too small.", windowId);
        return;
    }

    *foundWindowId = windowId;
    NSLog(@"Found window in %@ with size: %.1f x %.1f, id: %d", applicationName, bounds.size.width, bounds.size.height, windowId);
}

-(CGWindowID)findSNESWindowId
{
	// Ask the window server for the list of windows.
	CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    
	CGWindowID snesWindowId = kCGNullWindowID;
	CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowSearchFunction, &snesWindowId);
	CFRelease(windowList);
    
    return snesWindowId;
}

-(void)timerFired
{
    if (!_windowID)
        return;
    
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, _windowID, kCGWindowImageBoundsIgnoreFraming | kCGWindowImageShouldBeOpaque);

    NSTimeInterval offset = -[_start timeIntervalSinceNow] * _speedMultiplier;
    [self.delegate nextFrame:windowImage atOffset:offset];
    CGImageRelease(windowImage);
}

@end
