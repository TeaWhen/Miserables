//
//  LesViewController.h
//  Miserables
//
//  Created by Xhacker on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISearchBar *search;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigation;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapNavigation;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapWebView;

@end
