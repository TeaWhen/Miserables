//
//  LesViewController.h
//  Miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

FOUNDATION_EXPORT NSString * const LesLoadArticleNotification;

@interface LesViewController : UIViewController

- (void)handleLoadArticle:(NSNotification *)note;

@end
