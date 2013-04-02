//
//  LesDownloader.m
//  miserables
//
//  Created by Meow on 13-4-2.
//  Copyright (c) 2013年 Eksband. All rights reserved.
//

#import "LesDownloader.h"
#import "AFDownloadRequestOperation.h"

@interface LesDownloader ()

@property AFDownloadRequestOperation *downloadOperation;

@end

@implementation LesDownloader

+ (LesDownloader *)singleton
{
    static LesDownloader *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{sharedInstance = [[self alloc] init];});
    return sharedInstance;
}

- (void)start
{
    id documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *currentLibraryPath = [documentDirectory stringByAppendingPathComponent:@"articles.db"];
    NSString *newLibraryPath = [documentDirectory stringByAppendingPathComponent:@"articles_new.db"];

    if (!self.downloadOperation) {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://42.121.18.11/static/mis/articles.db"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:12.0];
        self.downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:req targetPath:newLibraryPath shouldResume:YES];
        self.downloadOperation.shouldOverwrite = YES;
    }
    
    [self.downloadOperation start];
}

- (void)cancel
{
    [self.downloadOperation cancel];
    self.downloadOperation = nil;
}

@end
