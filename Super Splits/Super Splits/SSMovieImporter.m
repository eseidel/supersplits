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

#import <QTKit/QTKit.h>
#import "SSMovieImageSource.h"

@implementation SSMovieImporter

+(NSArray *)movieFileTypes
{
    return [QTMovie movieFileTypes:QTIncludeAllTypes];
}

-(SSRun *)scanRunFromMovieURL:(NSURL *)url
{
    QTMovie *movie = [QTMovie movieWithURL:url error:nil];
    [movie gotoBeginning];
    QTTime duration = [movie duration];

    NSDictionary *imageAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     QTMovieFrameImageTypeCGImageRef, QTMovieFrameImageType
                                     , nil];
    NSError *error = nil;
    QTTime stepSize = QTMakeTimeWithTimeInterval(1.0);
    
    SSRunBuilder *runBuilder = [[SSRunBuilder alloc] init];
    while (true) {
        QTTime currentTime = [movie currentTime];
        if (QTTimeCompare(currentTime, duration) != NSOrderedAscending)
            break;

        NSTimeInterval offset;
        BOOL success = QTGetTimeInterval(currentTime, &offset);
        assert(success);

        CGImageRef image = [movie frameImageAtTime:currentTime withAttributes:imageAttributes error:&error];
        if (!image || error) {
            NSLog(@"Error getting frame at %@ in %@: %@", QTStringFromTime(currentTime), [url lastPathComponent], error);
            break;
        }

        SSMetroidFrame *frame = [[SSMetroidFrame alloc] initWithCGImage:image];
        if (!frame) {
            NSLog(@"Error processing frame at %@ in %@", QTStringFromTime(currentTime), [url lastPathComponent]);
            break;
        }
        [runBuilder updateWithFrame:frame atOffset:offset];
        [movie setCurrentTime:QTTimeIncrement(currentTime, stepSize)];
        CGImageRelease(image); // FIXME: This is likely wrong, but seems to stop our unbounded heap growth. :)
    }
    return [runBuilder run];
}

@end
