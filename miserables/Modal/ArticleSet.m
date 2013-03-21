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

@interface ArticleSet ()

@property FMDatabase *DB;
- (void)openDB;

@end

@implementation ArticleSet

- (id)init {
    self = [super init];
    
    if (self) {
        [self openDB];
        [self.DB executeUpdate:@"CREATE TABLE IF NOT EXISTS Articles (title TEXT, content TEXT)"];
        
        FMResultSet *rs = [self.DB executeQuery:@"SELECT COUNT(*) FROM Articles"];
        int articleCount = 0;
        if ([rs next]) {
            articleCount = [rs intForColumnIndex:0];
        }
        
        if (articleCount == 0) {
            NSString *sql = @"INSERT INTO Articles (title, content) VALUES (?, ?)";
            [self.DB executeUpdate:sql, @("首页"), @("您还没有安装资料库，请进入设置页下载。（若网络连接较慢，也可通过「iTunes 文件共享」导入。）")];
        }
    }
    
    return self;
}

- (void)openDB
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *DBPath = [documentDirectory stringByAppendingPathComponent:@"articles.db"];
    
    self.DB = [FMDatabase databaseWithPath:DBPath];
    if (![self.DB open]) {
        NSLog(@"Could not open db.");
    }
    
    self.DB.traceExecution = YES;
    self.DB.logsErrors = YES;
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
    if ([rs next]) {
        return [rs stringForColumn:@"content"];
    }
    return nil;
}

- (NSInteger)count
{
    FMResultSet *rs = [self.DB executeQuery:@"SELECT COUNT(*) FROM Articles"];
    if ([rs next]) {
        return [rs intForColumnIndex:0];
    }
    return 0;
}

@end
