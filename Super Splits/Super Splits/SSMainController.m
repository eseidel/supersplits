//
//  SSMainController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMainController.h"
#import "SSMetroidFrame.h"

@implementation SSMainController

@synthesize currentRun=_run, debugImageView=_debugImageView, referenceRun=_referenceRun;

-(id)init
{
    if (self = [super init]) {
        _imageSource = [[SSWindowImageSource alloc] init];
        _imageSource.delegate = self;
        _referenceRun = [[SSRunController alloc] initWithContentsOfURL:[self referenceRunURL]];
        [self resetRun];
    }
    return self;
}

-(BOOL)running
{
    return _imageSource.polling;
}

-(void)startRun
{
    [_imageSource startPollingWithInterval:(1.0 / 30.0)];
}

-(void)stopRun
{
    [_imageSource stopPolling];
}

-(void)resetRun
{
    _run = [[SSRunController alloc] init];
}
                      
-(NSURL *)referenceRunURL
{
    return [[self runsDirectoryURL] URLByAppendingPathComponent:@"reference.txt"];
}

-(NSURL *)runsDirectoryURL
{
    NSString *runsPath = @"~/Library/Application Support/Super Splits/";
    runsPath = [runsPath stringByExpandingTildeInPath];
    NSURL *runsURL = [NSURL fileURLWithPath:runsPath];
    [[NSFileManager defaultManager] createDirectoryAtURL:runsURL withIntermediateDirectories:YES attributes:nil error:nil];
    return runsURL;
}

-(void)nextFrame:(CGImageRef)image
{
    SSMetroidFrame *frame = [[SSMetroidFrame alloc] initWithCGImage:image];
    // FIXME: We may want to log when we get an unsupported image.
    if (!frame) {
        NSLog(@"Unsupported image!");
        return;
    }

    if (frame.isMissingEnergyText) {
        _run.state = BlackScreenState;
    } else if (frame.isMostlyBlack) {
        _run.state = RoomTransitionState;
    } else {
        _run.state = RoomState;
        _run.roomName = frame.miniMapString;
    }

    if (_debugImageView)
        [_debugImageView setImage:[frame createDebugImage]];
}

@end
