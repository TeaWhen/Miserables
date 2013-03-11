//
//  LesNavigationController.h
//  miserables
//
//  Created by Xhacker on 2013-03-11.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFDownloadRequestOperation.h"

@interface LesNavigationController : UINavigationController {
@public
    BOOL downloaded;
}

+ (instancetype)cast:(id)from;

@property (strong, nonatomic) AFDownloadRequestOperation *downloadOperation;

@end
