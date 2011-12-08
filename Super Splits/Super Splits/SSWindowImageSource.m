//
//  SNESImageSource.m
//  Super Splits
//
//  Created by Eric Seidel on 12/7/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSWindowImageSource.h"

@implementation SSWindowImageSource

@synthesize delegate=_delegate;

-(BOOL)startPollingWithInterval:(NSTimeInterval)interval
{
    assert(!_timer);
    _windowID = [self findSNESWindowId];
    if (!_windowID)
        return NO;

    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(timerFired)
                                            userInfo:self
                                             repeats:true];
    return YES;
}

-(BOOL)polling
{
    return (BOOL)_timer;
}

-(void)stopPolling
{
    assert(_timer);
    [_timer invalidate];
    _timer = nil;
    _windowID = kCGNullWindowID;
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

-(void)timerFired
{
    if (!_windowID)
        return;
    
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, _windowID, kCGWindowImageBoundsIgnoreFraming | kCGWindowImageShouldBeOpaque);
    
    [_delegate nextFrame:windowImage];
    CGImageRelease(windowImage);
}

@end
