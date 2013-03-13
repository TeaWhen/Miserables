//
//  LesNavigationController.h
//  miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-11.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "AFDownloadRequestOperation.h"

@interface LesNavigationController : UINavigationController {
@public
    BOOL downloaded;
}

@property (strong, nonatomic) AFDownloadRequestOperation *downloadOperation;
@property (strong, nonatomic) FMDatabase *db;

+ (instancetype)cast:(id)from;
- (void)openDb;

@end
