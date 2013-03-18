//
//  LesNavigationController.m
//  miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-11.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesNavigationController.h"

@interface LesNavigationController ()

@property (strong, nonatomic) NSString *dbPath;

@end

@implementation LesNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self->downloaded = NO;
    
}

- (void)openDb
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"article.db"];
    
    self.db = [FMDatabase databaseWithPath:dbPath];
    if (![self.db open]) {
        NSLog(@"Could not open db.");
    }
    
    [self.db executeUpdate:@"CREATE TABLE Article (title TEXT, content TEXT)"];
    [self.db executeUpdate:@"CREATE TABLE Favorite (title TEXT)"];

    FMResultSet *s = [self.db executeQuery:@"SELECT COUNT(*) FROM Article"];
    int articleCount = 0;
    if ([s next]) {
        articleCount = [s intForColumnIndex:0];
    }
    
    if (articleCount == 0) {
        NSString *sql = @"INSERT INTO Article (title, content) VALUES (?, ?)";
        [self.db executeUpdate:sql, @("首页"), @("您还没有安装资料库，请进入设置页下载。（若网络连接较慢，也可通过「iTunes 文件共享」导入。）")];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
