//
//  LesViewController.h
//  Miserables
//
//  Created by Xhacker on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface LesViewController : UIViewController

@property (strong, nonatomic) FMDatabase *db;

- (void)openDb;

@end
