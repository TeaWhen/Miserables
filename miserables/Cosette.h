//
//  Cosette.h
//  miserables
//
//  Created by Xhacker on 2013-04-08.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cosette : NSObject

+ (Cosette *)me;
- (void)requestVersionWithSuccess:(void (^)(id JSON))success failure:(void (^)(NSError *error))failure;
- (void)requestNoticeWithSuccess:(void (^)(id JSON))success failure:(void (^)(NSError *error))failure;
- (void)getNewNoticeWithCallback:(void (^)(NSString *content))callback;
- (void)requestLibrariesWithSuccess:(void (^)(id JSON))success failure:(void (^)(NSError *error))failure;

@end
