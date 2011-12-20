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

    SSRunBuilder *runBuilder = [[SSRunBuilder alloc] init];
    while (true) {
        QTTime currentTime = [movie currentTime];
        if (QTTimeCompare(currentTime, duration) != NSOrderedAscending)
            break;

        NSTimeInterval offset;
        BOOL success = QTGetTimeInterval(currentTime, &offset);
        assert(success);

        // I doubt this is particularly efficient.
        NSImage *image = [movie currentFrameImage];
        CGImageRef cgImage = [image CGImageForProposedRect:nil context:nil hints:nil];
        SSMetroidFrame *frame = [[SSMetroidFrame alloc] initWithCGImage:cgImage];
        if (!frame) {
            NSLog(@"Error processing frame at %@ in %@", QTStringFromTime(currentTime), [url lastPathComponent]);
            return nil;
        }
        CGImageRelease(cgImage);
        [runBuilder updateWithFrame:frame atOffset:offset];
    }
    return [runBuilder run];
}

@end
