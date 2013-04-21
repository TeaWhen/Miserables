//
//  LesDownloader.h
//  miserables
//
//  Created by Meow on 13-4-2.
//  Copyright (c) 2013年 Eksband. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LesDownloaderDelegate <NSObject>

- (void)downloadCompleted;
- (void)downloadFailed:(NSError *)error withStatusCode:(NSInteger)statusCode;
- (void)downloaded:(long long)currentBytes of:(long long)totalBytes;

@end


@interface LesDownloader : NSObject

+ (LesDownloader *)singleton;
- (void)start;
- (void)cancel;

@property id<LesDownloaderDelegate> delegate;
@property BOOL downloaded;
@property NSURL *url;
@property NSString *md5;

// TODO
- (void)pause;

@end
