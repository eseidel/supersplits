//
//  SSMainController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMainController.h"

@implementation SSMainController

@synthesize running=_running, currentRun=_run, debugImageView=_debugImageView;

-(id)init
{
    if (self = [super init]) {
        _imageProcessor = [[SSImageProcessor alloc] init];
        _imageSource = [[SNESImageSource alloc] init];
        _imageSource.delegate = self;
        [self resetRun];
    }
    return self;
}

-(void)startRun
{
    assert(!_running);
    _running = YES;
    [_imageSource startPollingWithInterval:(1.0 / 30.0)];
}

-(void)stopRun
{
    assert(_running);
    [_imageSource stopPolling];
    _running = NO;
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

-(void)nextFrame:(CGImageRef)frame
{
    // Look for if the image is a transition screen.
    // If it's a transition screen, print room time and reset the room timer.
    if ([_imageProcessor isTransitionScreen:frame]) {
        if (![_run inTransition])
            [_run startTransition];
    } else {
        if ([_run inTransition])
            [_run endTransition];
    }
    if (_debugImageView) {
        [_debugImageView setImage:[_imageProcessor createDebugImage:frame]];
    }
}

@end
