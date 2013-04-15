//
//  RecentSet.m
//  miserables
//
//  Created by Yan Zheng on 13-4-3.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "RecentSet.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface RecentSet ()

@property FMDatabase *DB;
@property NSMutableArray *recents;
- (void)initDB;
- (void)reload;

@end

@implementation RecentSet

+ (RecentSet *)singleton
{
    static RecentSet *sharedInstance = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{sharedInstance = [[self alloc] init];});
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initDB];
        [self.DB executeUpdate:@"CREATE TABLE IF NOT EXISTS Recents (title TEXT, timestamp INTEGER)"];
    }

    return self;
}

- (void)initDB
{
    if (!self.DB) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [path objectAtIndex:0];
        NSString *DBPath = [documentDirectory stringByAppendingPathComponent:@"recents.db"];
        
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

- (NSMutableArray *)list
{
    // !! LOW EFFICIENCY
    [self reload];
    return self.recents;
}

- (void)reload
{
    FMResultSet *rs = [self.DB executeQuery:@"SELECT * FROM Recents ORDER BY timestamp DESC"];
    self.recents = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSString *title = [rs stringForColumn:@"title"];
        [self.recents addObject:title];
    }
}

- (BOOL)exist:(NSString *)title
{
    FMResultSet *s = [self.DB executeQuery:@"SELECT * FROM Recents WHERE title = ?", title];
    if ([s next]) {
        return YES;
    }
    return NO;
}

- (void)add:(NSString *)title
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    [self.DB executeUpdate:@"INSERT INTO Recents (title, timestamp) VALUES (?, ?)", title, [NSString stringWithFormat:@"%d", (NSInteger)timestamp]];
    [self reload];
}

- (void)update:(NSString *)title
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    [self.DB executeQuery:@"UPDATE Recents SET timestamp = ? WHERE title = ?", [NSString stringWithFormat:@"%d", (NSInteger)timestamp], title];
    [self reload];
}

- (void)remove:(NSString *)title
{
    [self.DB executeUpdate:@"DELETE FROM Recents WHERE title = ?", title];
    [self reload];
}

- (void)removeAll
{
    [self.DB executeUpdate:@"DELETE FROM Recents"];
    [self reload];
}

- (NSInteger)count
{
    if (!self.recents) {
        [self list];
    }
    
    return self.recents.count;
}

@end
