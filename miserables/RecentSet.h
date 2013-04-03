//
//  RecentSet.h
//  miserables
//
//  Created by Yan Zheng on 13-4-3.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentSet : NSObject

+ (RecentSet *)singleton;
- (void)close;
- (NSMutableArray *)list;
- (BOOL)exist:(NSString *)title;
- (void)add:(NSString *)title;
- (void)update:(NSString *)title;
- (void)delete:(NSString *)title;
- (NSInteger)count;

@end
