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

@synthesize progress=_progress;

+(NSArray *)movieFileTypes
{
    return [AVURLAsset audiovisualTypes];
}

-(void)scanRunFromMovieURL:(NSURL *)url
{
    AVAsset *myAsset = [AVAsset assetWithURL:url];
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
//    _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
//    _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;

    Float64 frameStepSeconds = .5;
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

    AVAssetImageGeneratorCompletionHandler completionHandler = ^(CMTime requestedTime,
                                                                 CGImageRef image,
                                                                 CMTime actualTime,
                                                                 AVAssetImageGeneratorResult result,
                                                                 NSError *error) {
        // FIXME: We may need code to avoid duplicate updates when actualTime
        // does not change from last actualTime.
        if (result == AVAssetImageGeneratorSucceeded) {
            SSMetroidFrame *frame = [[SSMetroidFrame alloc] initWithCGImage:image];
            if (!frame) {
                NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
                NSLog(@"Error processing frame at %@", actualTimeString);
                return;
            }
            [runBuilder updateWithFrame:frame atOffset:CMTimeGetSeconds(actualTime)];
        }

        if (result == AVAssetImageGeneratorFailed)
            NSLog(@"Failed with error: %@", [error localizedDescription]);
        // NOTE: This canceled is called for every requested image!
        if (result == AVAssetImageGeneratorCancelled)
            NSLog(@"Canceled");

        framesRecieved++;
        if (framesRecieved % updateProgessEveryNFrames == 0) {
            Float64 currentSeconds = CMTimeGetSeconds(actualTime);
            Float64 percentComplete = currentSeconds / durationSeconds;
            //NSLog(@"Updating %0.2f of %0.2f (%0.2f)", currentSeconds, durationSeconds, percentComplete);
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
    [[_importWindowController window] makeKeyAndOrderFront:self];
}

-(void)cancelImport
{
    [_imageGenerator cancelAllCGImageGeneration];
}

-(void)_importFinished:(SSRun *)run
{
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
