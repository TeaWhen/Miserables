//
//  Favorites.h
//  miserables
//
//  Created by Xhacker on 2013-03-20.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteSet : NSObject

- (NSMutableArray *)list;
- (BOOL)exist:(NSString *)title;
- (void)add:(NSString *)title;
- (void)delete:(NSString *)title;

@end
