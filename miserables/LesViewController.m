//
//  LesViewController.m
//  Miserables
//
//  Created by Xhacker on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesViewController.h"

@interface LesViewController ()

@end

@implementation LesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tapNavigation = [self.tapNavigation initWithTarget:self action: @selector(navigationClicked:)];
    self.tapNavigation.numberOfTapsRequired = 2;
    [self.navigation addGestureRecognizer: self.tapNavigation];
    
    self.tapWebView = [self.tapWebView initWithTarget:self action:@selector(webViewClicked)];
    self.tapWebView.numberOfTapsRequired = 1;
    [self.webView addGestureRecognizer: self.tapWebView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) navigationClicked:(UIPanGestureRecognizer *) tapNavigation
{
    [self.search setHidden:NO];
}

- (void) webViewClicked:(UIPanGestureRecognizer *) tapWebView
{
    [self.search setHidden:YES];
}

@end
