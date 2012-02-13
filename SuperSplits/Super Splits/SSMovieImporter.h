//
//  SSMovieImporter.h
//  Super Splits
//
//  Created by Eric Seidel on 12/19/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSImportWindowController;
@class AVAssetImageGenerator;
@class SSMetroidFrame;

@interface SSMovieImporter : NSObject
{
    AVAssetImageGenerator *_imageGenerator;
    SSImportWindowController *_importWindowController;
    NSDate *_scanStart;
}

// FIXME: Unclear if we want to support importing more than one file at once.
@property (retain) NSNumber *progress;
@property (retain) SSMetroidFrame *lastFrame;

+(NSArray *)movieFileTypes;

-(void)scanRunFromMovieURL:(NSURL *)url;
-(void)cancelImport;

@end
