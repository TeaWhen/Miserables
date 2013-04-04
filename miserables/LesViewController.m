//
//  LesViewController.m
//  Miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesViewController.h"
#import "WebViewProxy.h"
#import "FavoriteSet.h"
#import "RecentsSet.h"
#import "ArticleSet.h"

@interface LesViewController () <UIWebViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSString *title;

- (void)setSearchIconToFavorites;

@end

@implementation LesViewController

static NSOperationQueue *queue;

- (void)viewDidLoad
{
    [super viewDidLoad];
       
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    
    self.webView.delegate = self;
    self.searchBar.delegate = self;
    
    for (UIView *searchBarSubview in [self.searchBar subviews]) {
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyGo];
            }
            @catch (NSException * e) {
                // ignore exception
            }
        }
    }
    
    [self setSearchIconToFavorites];
    
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

- (void)loadArticle:(NSString *)title
{
    RecentsSet *rec = [RecentsSet singleton];
    [rec add:title];
    
    self.title = title;

    self.navigationController.navigationBar.topItem.title = title;
    
    NSString *html_head = @"<link rel='stylesheet' href='http://foo.com/css/main.css' type='text/css' />";
    NSString *html_body;
    
    ArticleSet *articleSet = [ArticleSet singleton];
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

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [self performSegueWithIdentifier:@"favorites" sender:self];
}

- (void) searchBarSearchButtonClicked:(UISearchBar*) searchBar
{
    NSString *title = [self.searchBar text];
    [self loadArticle:title];
}

- (void)setSearchIconToFavorites
{
    UITextField *searchField = nil;
    for (UIView *subview in self.searchBar.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchField = (UITextField *)subview;
            break;
        }
    }
    if (searchField) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [button addTarget:self action:@selector(favoriteClicked:) forControlEvents:UIControlEventTouchUpInside];
        searchField.leftView = button;
    }
}

- (void)favoriteClicked:(UIButton *)sender {
    FavoriteSet *favs = [FavoriteSet singleton];
    if ([favs exist:self.title]) {
        [favs remove:self.title];
    }
    else {
        [favs add:self.title];
    }
}

@end
