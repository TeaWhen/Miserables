//
//  Articles.m
//  miserables
//
//  Created by Xhacker on 2013-03-20.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "ArticleSet.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "NSData+Godzippa.h"

@interface ArticleSet ()

@property FMDatabase *DB;
- (void)initDB;

@end

@implementation ArticleSet

+ (ArticleSet *)singleton
{
    static ArticleSet *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{sharedInstance = [[self alloc] init];});
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initDB];
        [self.DB executeUpdate:@"CREATE TABLE IF NOT EXISTS Articles (title TEXT, content TEXT)"];
        
        FMResultSet *rs = [self.DB executeQuery:@"SELECT COUNT(*) FROM Articles"];
        int articleCount = 0;
        if ([rs next]) {
            articleCount = [rs intForColumnIndex:0];
        }
        
        if (articleCount == 0) {
            NSString *sql = @"INSERT INTO Articles (title, content) VALUES (?, ?)";
            [self.DB executeUpdate:sql, @("Main Page"), @("You haven't install the library, please go to Settings and download. (If the network is slow, you can also use iTunes File Sharing to import the library.)")];
        }
    }

    return self;
}

- (void)initDB
{
    if (!self.DB) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [path objectAtIndex:0];
        NSString *DBPath = [documentDirectory stringByAppendingPathComponent:@"articles.db"];
        
        self.DB = [FMDatabase databaseWithPath:DBPath];
        [self open];
        
        self.DB.traceExecution = YES;
        self.DB.logsErrors = YES;
    }
}

- (void)open
{
    if (![self.DB open]) {
        NSLog(@"Could not open db.");
    }
}

- (void)close
{
    if (![self.DB close]) {
        NSLog(@"Could not close db.");
    }
}

- (void)reload
{
    [self close];
    [self open];
}

- (NSMutableArray *)articlesByKeyword:(NSString *)keyword
{
    FMResultSet *rs = [self.DB executeQuery:@"SELECT * FROM Articles WHERE title LIKE ?", [NSString stringWithFormat:@"%@%%", keyword]];
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSString *title = [rs stringForColumn:@"title"];
        [articles addObject:title];
    }

    return articles;
}

- (NSString *)articleByTitle:(NSString *)title
{
    FMResultSet *rs = [self.DB executeQuery:@"SELECT * FROM Articles WHERE title = ?", title];
    if (![rs next]) {
        rs = [self.DB executeQuery:@"SELECT * FROM Articles WHERE title = ? COLLATE NOCASE", title];
        if (![rs next]) {
            return nil;
        }
    }
    
    NSData *content = [rs dataForColumn:@"content"];
    if ([title isEqualToString:@"Main Page"])
    {
        return [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
    }
    return [self decompressData:content];
}

- (NSInteger)count
{
    FMResultSet *rs = [self.DB executeQuery:@"SELECT COUNT(*) FROM Articles"];
    if ([rs next]) {
        return [rs intForColumnIndex:0];
    }
    return 0;
}

- (NSString *)decompressData:(NSData *)compressedData
{
    NSData *decompressedData = [compressedData dataByGZipDecompressingDataWithError:nil];
    NSString *decompressedString = [NSString stringWithUTF8String:[decompressedData bytes]];
    return decompressedString;
}

@end
