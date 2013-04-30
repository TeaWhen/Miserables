//
//  LesDownloader.m
//  miserables
//
//  Created by Meow on 13-4-2.
//  Copyright (c) 2013年 Eksband. All rights reserved.
//

#import "LesDownloader.h"
#import "AFDownloadRequestOperation.h"
#import <CommonCrypto/CommonDigest.h>

@interface LesDownloader ()

@property AFDownloadRequestOperation *downloadOperation;

+ (NSString *)fileMD5:(NSString *)path;

@end

@implementation LesDownloader

+ (LesDownloader *)singleton
{
    static LesDownloader *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{sharedInstance = [[self alloc] init];});
    return sharedInstance;
}

+ (NSString *)fileMD5:(NSString *)path
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (handle == nil) {
        return nil;
    }
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    const NSInteger chunk_size = 512;
    while (!done) {
        NSData *fileData = [handle readDataOfLength:chunk_size];
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if ([fileData length] == 0) {
            done = YES;
        }
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

- (void)start
{
    id documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *currentLibraryPath = [documentDirectory stringByAppendingPathComponent:@"articles.db"];
    NSString *newLibraryPath = [documentDirectory stringByAppendingPathComponent:@"articles_new.db"];

    if (!self.downloadOperation) {
        NSURLRequest *req = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:12.0];
        self.downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:req targetPath:newLibraryPath shouldResume:YES];
        self.downloadOperation.shouldOverwrite = YES;

        __weak LesDownloader *weakSelf = self;
        
        [self.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", newLibraryPath);
            
            NSString *md5 = [LesDownloader fileMD5:newLibraryPath];
            NSLog(@"MD5: %@", md5);
            if (md5 == weakSelf.md5) {
                NSFileManager *fm = [NSFileManager defaultManager];
                [fm removeItemAtPath:currentLibraryPath error:nil];
                [fm moveItemAtPath:newLibraryPath toPath:currentLibraryPath error:nil];
                
                // TODO: better use a time instead.
                weakSelf.downloaded = YES;
                [weakSelf.delegate downloadCompleted];
            }
            else {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Downloaded file is corrupt, please try again."                                                                      forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"" code:-1 userInfo:userInfo];
                [weakSelf.delegate downloadFailed:error withStatusCode:0];
                [weakSelf.downloadOperation deleteTempFileWithError:nil];
                weakSelf.downloadOperation = nil;
            }
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

// TODO
- (void)pause
{
    ;
}

- (void)cancel
{
    [self.downloadOperation cancel];
    self.downloadOperation = nil;
}

@end
