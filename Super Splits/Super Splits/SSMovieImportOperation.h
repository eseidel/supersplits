//
//  SSMovieImportOperation.h
//  Super Splits
//
//  Created by Eric Seidel on 12/26/11.
//  Copyright (c) 2011 Eric Seidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSRun;
@class SSMovieImporter;

@interface SSMovieImportOperation : NSOperation
{
    QTMovie *_movie;
    SSMovieImporter *_importer;
}

@property (retain, readonly) SSRun *completedRun;

- (id)initWithMovie:(QTMovie *)movie importer:(SSMovieImporter *)importer;

@end
