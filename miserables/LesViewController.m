//
//  LesViewController.m
//  Miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesViewController.h"
#import "LesNavigationController.h"
#import "FMResultSet.h"
#import "WebViewProxy.h"

@interface LesViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapNavigation;

@end

@implementation LesViewController

static NSOperationQueue* queue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    
    self.nav = (LesNavigationController *)(self.navigationController);
    [self.nav openDb];
    
    self.tapNavigation = [self.tapNavigation initWithTarget:self action: @selector(navigationBarClicked:)];
    self.tapNavigation.numberOfTapsRequired = 2;
    [self.navigationController.navigationBar addGestureRecognizer:self.tapNavigation];
    self.webView.delegate = self;
    
    [WebViewProxy handleRequestsWithHost:@"foo.com" handler:^(NSURLRequest* req, WVPResponse *res) {
        NSString *URL = [req.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *fileName = [[URL substringFromIndex:14] stringByReplacingOccurrencesOfString:@"#__webviewproxyreq__" withString:@""];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[@"/Static" stringByAppendingString:fileName] ofType:nil];
        [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        NSString *CSS = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [res respondWithText:CSS];
    }];
    
    // default page
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"miserables://%@", [@"首页" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) navigationBarClicked:(UIPanGestureRecognizer *) tapNavigation
{
    [self performSegueWithIdentifier:@"search" sender:self];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqual: @"miserables"]) {
        NSString *URL = [request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        /* miserables:// */
        NSString *title = [NSString stringWithString:[URL substringFromIndex:13]];

        self.navigationController.navigationBar.topItem.title = title;
        
        NSString *html_head = @"<link rel='stylesheet' href='http://foo.com/css/main.css' type='text/css' />";
        NSString *html_body;

        FMResultSet *articles = [self.nav.db executeQuery:@"SELECT * FROM Article WHERE title = ?", title];
        if ([articles next]) {
            html_body = [articles stringForColumn:@"content"];
        }
        else {
            html_body = @"未找到条目。";
        }

        NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", html_head, html_body];

        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        [self.webView loadHTMLString:html baseURL:baseURL];
        return NO;
    }
    else {
        return YES;
    }
}

@end
