//
//  Favorites.m
//  miserables
//
//  Created by Xhacker on 2013-03-20.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "FavoriteSet.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface FavoriteSet ()

@property FMDatabase *DB;
@property NSMutableArray *favorites;
- (void)openDB;
- (void)updateSequence;

@end

@implementation FavoriteSet

- (id)init {
    self = [super init];
    
    if (self) {
        [self openDB];
        [self.DB executeUpdate:@"CREATE TABLE IF NOT EXISTS Favorites (title TEXT, sequence INT, timestamp INTEGER)"];
    }
    
    return self;
}

- (void)openDB
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *DBPath = [documentDirectory stringByAppendingPathComponent:@"favorites.db"];
    
    self.DB = [FMDatabase databaseWithPath:DBPath];
    if (![self.DB open]) {
        NSLog(@"Could not open db.");
    }
    
    self.DB.traceExecution = YES;
    self.DB.logsErrors = YES;
}

- (NSMutableArray *)list
{
    if (!self.favorites) {
        FMResultSet *rs = [self.DB executeQuery:@"SELECT * FROM `Favorites` ORDER BY `sequence` DESC, `timestamp` ASC"];
        self.favorites = [[NSMutableArray alloc] init];
        while ([rs next]) {
            NSString *title = [rs stringForColumn:@"title"];
            [self.favorites addObject:title];
        }
    }
    
    return self.favorites;
}

- (BOOL)exist:(NSString *)title
{
    FMResultSet *s = [self.DB executeQuery:@"SELECT * FROM Favorites WHERE title = ?", title];
    if ([s next]) {
        return YES;
    }
    return NO;
}

- (void)add:(NSString *)title
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    [self.DB executeUpdate:@"INSERT INTO Favorites (title, timestamp, sequence) VALUES (?, ?, 0)", title, [NSString stringWithFormat:@"%d", (NSInteger)timestamp]];
}

- (void)delete:(NSString *)title
{
    [self.DB executeUpdate:@"DELETE FROM Favorites WHERE title = ?", title];
}

- (void)deleteAtRow:(NSInteger)row
{
    NSString *title = [self.favorites objectAtIndex:row];
    [self.favorites removeObjectAtIndex:row];
    [self delete:title];
}

- (void)moveRow:(NSInteger)sourceRow toRow:(NSInteger)destinationRow
{
    NSString *title = [self.favorites objectAtIndex:sourceRow];
    [self.favorites removeObjectAtIndex:sourceRow];
    [self.favorites insertObject:title atIndex:destinationRow];
}

- (void)updateSequence
{
    for (NSInteger i = 0; i < [self.favorites count]; ++i) {
        [self.DB executeUpdate:@"UPDATE Favorites SET sequence = ? WHERE title = ?", i, [self.favorites objectAtIndex:i]];
    }
}

- (NSInteger)count
{
    if (!self.favorites) {
        [self list];
    }
    
    return self.favorites.count;
}

@end
