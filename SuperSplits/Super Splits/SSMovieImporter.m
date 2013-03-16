//
//  SSMovieImporter.m
//  Super Splits
//
//  Created by Eric Seidel on 12/19/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMovieImporter.h"
#import "SSMetroidFrame.h"
#import "SSRunBuilder.h"
#import "SSRunDocument.h"

#import <AVFoundation/AVFoundation.h>
#import "SSImportWindowController.h"

@interface SSMovieImporter (PrivateMethods)

-(void)_importFinished:(SSRun *)run;

@end


@implementation SSMovieImporter

@synthesize progress=_progress, lastFrame=_lastFrame;

+(NSArray *)movieFileTypes
{
    return [AVURLAsset audiovisualTypes];
}

-(void)scanRunFromMovieURL:(NSURL *)url
{
    AVAsset *myAsset = [AVAsset assetWithURL:url];
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    Float64 frameStepSeconds = .5;

    _imageGenerator.requestedTimeToleranceBefore = CMTimeMakeWithSeconds(frameStepSeconds, 600);
    _imageGenerator.requestedTimeToleranceAfter = CMTimeMakeWithSeconds(frameStepSeconds, 600);

    Float64 durationSeconds = CMTimeGetSeconds([myAsset duration]);
    NSUInteger frameCount = durationSeconds / frameStepSeconds;
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:frameCount];
    for (NSUInteger i = 0; i < frameCount; i++) {
        CMTime time = CMTimeMakeWithSeconds(i * frameStepSeconds, 600);
        [times addObject:[NSValue valueWithCMTime:time]];
    }

    SSRunBuilder *runBuilder = [[SSRunBuilder alloc] init];

    const NSInteger updateProgessEveryNFrames = 10;
    __block NSInteger framesRecieved = 0;
    __block CMTime lastActualTime = kCMTimeInvalid;

    AVAssetImageGeneratorCompletionHandler completionHandler = ^(CMTime requestedTime,
                                                                 CGImageRef image,
                                                                 CMTime actualTime,
                                                                 AVAssetImageGeneratorResult result,
                                                                 NSError *error) {
        if (result == AVAssetImageGeneratorFailed) {
            NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
            NSLog(@"Failed with error: %@ at: %@", [error localizedDescription], actualTimeString);
        }

        if (result == AVAssetImageGeneratorSucceeded) {
            framesRecieved++;
            if (CMTimeCompare(lastActualTime, actualTime) == 0) {
                NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
                NSLog(@"Warning: Ignoring duplicate frame for time: %@", actualTimeString);
                return;
            }
            lastActualTime = actualTime;

            SSMetroidFrame *frame = [[SSMetroidFrame alloc] initWithCGImage:image];
            if (!frame) {
                NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
                NSLog(@"Error processing frame at %@", actualTimeString);
                return;
            }
            [runBuilder updateWithFrame:frame atOffset:CMTimeGetSeconds(actualTime)];
            [self performSelectorOnMainThread:@selector(setLastFrame:) withObject:frame waitUntilDone:NO];
        }

        if (framesRecieved % updateProgessEveryNFrames == 0) {
            Float64 currentSeconds = CMTimeGetSeconds(actualTime);
            Float64 percentComplete = currentSeconds / durationSeconds;
            NSNumber *progress = [NSNumber numberWithDouble:percentComplete * 100];
            [self performSelectorOnMainThread:@selector(setProgress:) withObject:progress waitUntilDone:NO];
        }
        if (framesRecieved == frameCount) {
            [self performSelectorOnMainThread:@selector(_importFinished:) withObject:runBuilder.run waitUntilDone:NO];
        }
    };

    [_imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:completionHandler];

    _importWindowController = [[SSImportWindowController alloc] initWithWindowNibName:@"ImportWindow"];
    _importWindowController.movieImporter = self;
    // FIXME: Should this be a modal window?
    NSWindow *window = [_importWindowController window];
    window.title = [NSString stringWithFormat:@"Importing '%@'", [url lastPathComponent]];
    [window makeKeyAndOrderFront:self];
    _scanStart = [NSDate date];
}

-(void)cancelImport
{
    [_imageGenerator cancelAllCGImageGeneration];
}

-(void)_importFinished:(SSRun *)run
{
    NSLog(@"Scan completed in %0.2fs", -[_scanStart timeIntervalSinceNow]);
    [[_importWindowController window] close];
    NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
    NSError *error = nil;
    SSRunDocument *document = [documentController openUntitledDocumentAndDisplay:YES error:&error];
    if (error) {
        NSLog(@"Error creating run document after import: %@", error);
        return;
    }
    document.run = run;
}

@end
