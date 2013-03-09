//
//  LesViewController.m
//  Miserables
//
//  Created by Xhacker on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesViewController.h"

@interface LesViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapNavigation;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tapNavigation = [self.tapNavigation initWithTarget:self action: @selector(navigationBarClicked:)];
    self.tapNavigation.numberOfTapsRequired = 2;
    [self.navigationBar addGestureRecognizer:self.tapNavigation];
    self.searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) navigationBarClicked:(UIPanGestureRecognizer *) tapNavigation
{
    [self.searchBar setHidden:NO];
    [self.searchBar becomeFirstResponder];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *) searchBar
{
    
}

- (void) searchBarCancelButtonClicked:(UISearchBar*) searchBar
{
    [self.searchBar setHidden:YES];
    [self.searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar*) searchBar
{
    NSMutableString *pageURL = [NSMutableString stringWithString:@"http://www.baidu.com/"];
    [pageURL appendString:[self.searchBar text]];
    NSURL *url = [NSURL URLWithString:pageURL];
    
    NSMutableString *html = [NSMutableString stringWithString:@"<html><head><style type=\"text/css\">"];
    [html appendString:@"body {font-size: px;} "];
    [html appendString:@"</style></head><body><h1>"];
    [html appendString:[self.searchBar text]];
    [html appendString:@"</h1><h2>据说很厉害！</h2></body></html>"];
    
    [self.webView loadHTMLString:html baseURL:url];
    [self.searchBar setHidden:YES];
    self.navigationBar.topItem.title = [self.searchBar text];
    [self.searchBar resignFirstResponder];
    [self.webView becomeFirstResponder];
}

@end
