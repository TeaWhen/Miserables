//
//  Favorites.m
//  miserables
//
//  Created by Xhacker on 2013-03-20.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "Favorites.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface Favorites ()

@property FMDatabase *DB;
- (void)openDB;

@end

@implementation Favorites

- (id)init {
    self = [super init];
    
    if (self) {
        [self openDB];
    }
    
    [self.DB executeUpdate:@"CREATE TABLE IF NOT EXISTS Favorites (title TEXT)"];
    
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
    FMResultSet *rs = [self.DB executeQuery:@"SELECT * FROM Favorites"];
    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSString *title = [rs stringForColumn:@"title"];
        [favorites addObject:title];
    }
    
    return favorites;
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
    [self.DB executeUpdate:@"INSERT INTO Favorites VALUES (?)", title];
}

- (void)delete:(NSString *)title
{
    [self.DB executeUpdate:@"DELETE FROM Favorites WHERE title = ?", title];
}

@end
