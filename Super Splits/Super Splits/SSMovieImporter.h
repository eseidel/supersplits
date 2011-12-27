//
//  SSMovieImporter.h
//  Super Splits
//
//  Created by Eric Seidel on 12/19/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSRun;
@class SSMovieImportOperation;
@class SSImportWindowController;

@interface SSMovieImporter : NSObject
{
    NSOperationQueue *_importQueue;
    SSImportWindowController *_importWindowController;
}

// FIXME: Unclear if we want to support importing more than one file at once.
@property (retain, readonly) SSMovieImportOperation *importOperation;
@property (retain) NSNumber *progress;

+(NSArray *)movieFileTypes;

-(void)scanRunFromMovieURL:(NSURL *)url;

@end
