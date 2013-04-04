//
//  RecentSet.m
//  miserables
//
//  Created by Yan Zheng on 13-4-3.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "RecentsSet.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface RecentsSet ()

@property FMDatabase *DB;
@property NSMutableArray *recent;
- (void)openDB;
- (void)updateSequence;
- (void)reload;

@end

@implementation RecentsSet

+ (RecentsSet *)singleton
{
    static RecentsSet *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{sharedInstance = [[self alloc] init];});
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self openDB];
        [self.DB executeUpdate:@"CREATE TABLE IF NOT EXISTS Recent (title TEXT, timestamp INTEGER)"];
    }

    return self;
}

- (void)openDB
{
    if (!self.DB) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [path objectAtIndex:0];
        NSString *DBPath = [documentDirectory stringByAppendingPathComponent:@"app.db"];
        
        self.DB = [FMDatabase databaseWithPath:DBPath];
        if (![self.DB open]) {
            NSLog(@"Could not open db.");
        }
        
        self.DB.traceExecution = YES;
        self.DB.logsErrors = YES;
    }
}

- (void)close
{
    if (self.DB) {
        if (![self.DB close]) {
            NSLog(@"Could not close db.");
        }
    }
}

- (NSMutableArray *)list
{
    if (!self.recent) {
        [self reload];
    }
    
    return self.recent;
}

- (void)reload
{
    FMResultSet *rs = [self.DB executeQuery:@"SELECT * FROM Recent ORDER BY timestamp"];
    self.recent = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSString *title = [rs stringForColumn:@"title"];
        [self.recent addObject:title];
    }
}

- (BOOL)exist:(NSString *)title
{
    FMResultSet *s = [self.DB executeQuery:@"SELECT * FROM Recent WHERE title = ?", title];
    if ([s next]) {
        return YES;
    }
    return NO;
}

- (void)add:(NSString *)title
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    [self.DB executeUpdate:@"INSERT INTO Recent (title, timestamp) VALUES (?, ?)", title, [NSString stringWithFormat:@"%d", (NSInteger)timestamp]];
    [self reload];
}

- (void)update:(NSString *)title
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    FMResultSet *s = [self.DB executeQuery:@"UPDATE Recent SET timestamp = ? WHERE title = ?", [NSString stringWithFormat:@"%d", (NSInteger)timestamp], title];
    [self reload];
}

- (void)delete:(NSString *)title
{
    [self.DB executeUpdate:@"DELETE FROM Recent WHERE title = ?", title];
    [self reload];
}

- (NSInteger)count
{
    if (!self.recent) {
        [self list];
    }
    
    return self.recent.count;
}

@end
