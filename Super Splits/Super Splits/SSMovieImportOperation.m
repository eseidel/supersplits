//
//  SSMovieImportOperation.m
//  Super Splits
//
//  Created by Eric Seidel on 12/26/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import "SSMovieImportOperation.h"

#import "SSMovieImporter.h"
#import "SSRunBuilder.h"
#import "SSMetroidFrame.h"

#import <QTKit/QTKit.h>

@implementation SSMovieImportOperation

@synthesize completedRun=_completedRun;

- (id)initWithMovie:(QTMovie *)movie importer:(SSMovieImporter *)importer
{
    if (self == [super init]) {
        _movie = movie;
        _importer = importer;
    }
    return self;
}

- (NSNumber *)percentTime:(QTTime)time ofTotalTime:(QTTime)totalTime
{
    NSTimeInterval offset;
    BOOL success = QTGetTimeInterval(time, &offset);
    assert(success);

    NSTimeInterval total;
    success = QTGetTimeInterval(totalTime, &total);
    assert(success);
    return [NSNumber numberWithDouble:offset / total];
}

- (void)main
{
    [QTMovie enterQTKitOnThread];
    if (![_movie attachToCurrentThread]) {
        [QTMovie exitQTKitOnThread];
        NSLog(@"Failed to attach movie on thread.");
        return;
    }

    [_movie gotoBeginning];
    QTTime duration = [_movie duration];
    QTTime currentTime = [_movie currentTime];

    NSDictionary *imageAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     QTMovieFrameImageTypeCGImageRef, QTMovieFrameImageType,
                                     [NSNumber numberWithBool:YES], QTMovieFrameImageSessionMode,
                                     nil];
    NSError *error = nil;
    QTTime stepSize = QTMakeTimeWithTimeInterval(1.0); // FIXME: This should be much shorter!

    const NSInteger updateProgessEveryNFrames = 10;

    NSInteger framesUntilProgressUpdate = updateProgessEveryNFrames;
    SSRunBuilder *runBuilder = [[SSRunBuilder alloc] init];
    while (!self.isCancelled) {
        if (QTTimeCompare(currentTime, duration) != NSOrderedAscending)
            break;

        NSTimeInterval offset;
        BOOL success = QTGetTimeInterval(currentTime, &offset);
        assert(success);

        // We use @autoreleasepool here to force the compiler to release the CGImageRef after each loop.
        @autoreleasepool {
            CGImageRef image = [_movie frameImageAtTime:currentTime withAttributes:imageAttributes error:&error];
            if (!image || error) {
                NSLog(@"Error getting frame at %@: %@", QTStringFromTime(currentTime), error);
                [self cancel];
                break;
            }

            SSMetroidFrame *frame = [[SSMetroidFrame alloc] initWithCGImage:image];
            if (!frame) {
                NSLog(@"Error processing frame at %@", QTStringFromTime(currentTime));
                [self cancel];
                break;
            }
            [runBuilder updateWithFrame:frame atOffset:offset];
        }
        currentTime = QTTimeIncrement(currentTime, stepSize);
        framesUntilProgressUpdate--;
        if (framesUntilProgressUpdate) {
            NSNumber *progress = [self percentTime:currentTime ofTotalTime:duration];
            [_importer performSelectorOnMainThread:@selector(setProgress:) withObject:progress waitUntilDone:NO];
        }
    }

    [_movie detachFromCurrentThread];
    [QTMovie exitQTKitOnThread];

    if (!self.isCancelled)
        _completedRun = runBuilder.run;
}

@end
