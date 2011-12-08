//
//  SSMainController.m
//  Super Splits
//
//  Created by Eric Seidel on 12/6/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMainController.h"

@implementation SSMainController

@synthesize currentRun=_run, debugImageView=_debugImageView;

-(id)init
{
    if (self = [super init]) {
        _imageProcessor = [[SSImageProcessor alloc] init];
        _imageSource = [[SSWindowImageSource alloc] init];
        _imageSource.delegate = self;
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
    _run = [[SSRun alloc] init];
}

-(void)nextFrame:(CGImageRef)frame
{
    // FIXME: We may want to log when we get an unsupported image.
    if (![_imageProcessor isSupportedImage:frame])
        return;

    if ([_imageProcessor isTransitionScreen:frame]) {
        if (![_run inTransition])
            [_run startTransition];
    } else {
        if ([_run inTransition])
            [_run endTransition];
    }

    if (_debugImageView)
        [_debugImageView setImage:[_imageProcessor createDebugImage:frame]];
}

@end
