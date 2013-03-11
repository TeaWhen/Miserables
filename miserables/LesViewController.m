//
//  LesViewController.m
//  Miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesViewController.h"
#import "FMResultSet.h"
#import "WebViewProxy.h"

@interface LesViewController () <UISearchBarDelegate, UIWebViewDelegate>

//@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapNavigation;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LesViewController

static NSOperationQueue* queue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    
    [self openDb];
    
    self.tapNavigation = [self.tapNavigation initWithTarget:self action: @selector(navigationBarClicked:)];
    self.tapNavigation.numberOfTapsRequired = 2;
    [self.navigationController.navigationBar addGestureRecognizer:self.tapNavigation];
    self.searchBar.delegate = self;
    self.webView.delegate = self;
    
    [WebViewProxy handleRequestsWithHost:@"foo.com" handler:^(NSURLRequest* req, WVPResponse *res) {
//        NSString *URL = [req.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Static/css/main.css" ofType:@"png"];
//        NSString *CSS = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [res respondWithText:@"body {color: #ff0000;}"];
    }];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"miserables://%@", [@"延伸" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    self.webView.autoresizingMask = UIViewAutoresizingNone;
}

- (void)openDb
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"article.db"];
    
    self.db = [FMDatabase databaseWithPath:dbPath] ;
    if (![self.db open]) {
        NSLog(@"Could not open db.");
    }
    
    [self.db executeUpdate:@"CREATE TABLE Article (title TEXT, content TEXT)"];
    
    FMResultSet *s = [self.db executeQuery:@"SELECT COUNT(*) FROM Article"];
    int articleCount = 0;
    if ([s next]) {
        articleCount = [s intForColumnIndex:0];
    }
    
    if (articleCount == 0) {
        NSString *sql = @"INSERT INTO Article (title, content) VALUES (?, ?)";
        NSString *yanshen = [@("延伸") stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.db executeUpdate:sql, @("天安门"), [NSString stringWithFormat:@("天安门上<a href='miserables://%@'>太阳</a>升"), yanshen]];
        [self.db executeUpdate:sql, @("延伸"), @("厉害死了！")];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) navigationBarClicked:(UIPanGestureRecognizer *) tapNavigation
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.searchBar setHidden:NO];
    [self.webView setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];
    [self.searchBar becomeFirstResponder];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *) searchBar
{
    
}

- (void) searchBarCancelButtonClicked:(UISearchBar*) searchBar
{
    [self.searchBar setHidden:YES];
    [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar*) searchBar
{
    NSString *title = [self.searchBar text];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"miserables://%@", [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    
    [self.searchBar setHidden:YES];
    [self.webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.searchBar resignFirstResponder];
    [self.webView becomeFirstResponder];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqual: @"miserables"]) {
        NSString *URL = [request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        /* miserables:// */
        NSString *title = [NSString stringWithString:[URL substringFromIndex:13]];

        self.navigationController.navigationBar.topItem.title = title;
        NSLog(@"%@", title);
        
        NSString *html_head = @"<link rel='stylesheet' href='http://foo.com/main.css' type='text/css' />";
        NSString *html_body;

        FMResultSet *articles = [self.db executeQuery:@"SELECT * FROM Article WHERE title = ?", title];
        if ([articles next]) {
            NSString *content = [articles stringForColumn:@"content"];
            html_body = [NSString stringWithFormat:@"<h1>%@</h1><p>%@</p></body></html>", title, content];
        }
        else {
            html_body = @"未找到条目。";
        }

        NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body</html>", html_head, html_body];

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
