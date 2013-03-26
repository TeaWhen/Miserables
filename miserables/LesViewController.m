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
#import "FavoriteSet.h"
#import "ArticleSet.h"

@interface LesViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapNavigation;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@property (strong, nonatomic) NSString *title;

@end

@implementation LesViewController

static NSOperationQueue *queue;

- (void)viewDidLoad
{
    [super viewDidLoad];
       
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
        
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
    [self loadArticle:@"Main Page"];
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

- (void)loadArticle:(NSString *)title
{
    self.title = title;
    
    self.navigationController.navigationBar.topItem.title = title;
    
    NSString *html_head = @"<link rel='stylesheet' href='http://foo.com/css/main.css' type='text/css' />";
    NSString *html_body;
    
    ArticleSet *articleSet = [[ArticleSet alloc] init];
    NSString *content = [articleSet articleByTitle:title];
    if (content) {
        html_body = content;
    }
    else {
        html_body = @"No entry found.";
    }
    
    NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", html_head, html_body];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // disable horizontal scrolling
    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
}

- (IBAction)favoriteClicked:(UIButton *)sender {
    FavoriteSet *favs = [[FavoriteSet alloc] init];
    if ([favs exist:self.title]) {
        [favs delete:self.title];
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_0.png"] forState:UIControlStateNormal];
    }
    else {
        [favs add:self.title];
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_1.png"] forState:UIControlStateNormal];
    }
}

@end
