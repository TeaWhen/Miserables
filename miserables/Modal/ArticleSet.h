//
//  Articles.h
//  miserables
//
//  Created by Xhacker on 2013-03-20.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleSet : NSObject

- (NSMutableArray *)articlesByKeyword:(NSString *)keyword;
- (NSString *)articleByTitle:(NSString *)title;
- (NSInteger)count;

@end
