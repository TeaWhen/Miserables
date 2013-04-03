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

        __weak LesDownloader *weakSelf = self;
        
        [self.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", newLibraryPath);
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:currentLibraryPath error:nil];
            [fm moveItemAtPath:newLibraryPath toPath:currentLibraryPath error:nil];

            // TODO: better use a time instead.
            weakSelf.downloaded = YES;
            [weakSelf.delegate downloadCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakSelf.delegate downloadFailed:error withStatusCode:[operation.response statusCode]];
            [weakSelf.downloadOperation deleteTempFileWithError:nil];
            weakSelf.downloadOperation = nil;
        }];
        
        [self.downloadOperation setProgressiveDownloadProgressBlock:^(AFHTTPRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            [weakSelf.delegate downloaded:totalBytesReadForFile of:totalBytesExpectedToReadForFile];
        }];
    }
    
    [self.downloadOperation start];
}

- (void)cancel
{
    [self.downloadOperation cancel];
    self.downloadOperation = nil;
}

@end
