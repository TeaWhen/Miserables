//
//  Favorites.h
//  miserables
//
//  Created by Xhacker on 2013-03-20.
//  Copyright (c) 2013 Eksband. All rights reserved.
//
//  IMPORTANT: Use more than one FavoriteSet object at the same time may cause problems.

#import <Foundation/Foundation.h>

@interface FavoriteSet : NSObject

+ (FavoriteSet *)singleton;
- (void)open;
- (void)close;

- (NSMutableArray *)list;
- (BOOL)exist:(NSString *)title;
- (void)add:(NSString *)title;
- (void)remove:(NSString *)title;
- (void)removeAtRow:(NSInteger)row;
- (void)moveRow:(NSInteger)sourceRow toRow:(NSInteger)destinationRow;
- (NSInteger)count;

@end
