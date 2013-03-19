//
//  LesViewController.h
//  Miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "LesNavigationController.h"

@interface LesViewController : UIViewController

@property (weak, nonatomic) LesNavigationController *nav;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) FMDatabase *favoriteDB;

- (void)openFavoriteDb;

@end
