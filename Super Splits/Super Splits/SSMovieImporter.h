//
//  SSMovieImporter.h
//  Super Splits
//
//  Created by Eric Seidel on 12/19/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSRun;

@interface SSMovieImporter : NSObject

+(NSArray *)movieFileTypes;

-(SSRun *)scanRunFromMovieURL:(NSURL *)url;

@end
