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
#import "RecentSet.h"
#import "ArticleSet.h"

NSString * const LesLoadArticleNotification = @"LesLoadArticle";

@interface LesViewController () <UIWebViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSString *title;
@property bool soul;
@property int soulCurId;

- (void)loadArticle:(NSString *)title;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadArticle:) name:LesLoadArticleNotification object:nil];
    
    UISwipeGestureRecognizer *backRecongnizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack:)];
    backRecongnizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.webView addGestureRecognizer:backRecongnizer];

    UISwipeGestureRecognizer *forwardRecongnizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goForward:)];
    forwardRecongnizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.webView addGestureRecognizer:forwardRecongnizer];
    
    self.soul = false;
    self.soulCurId = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack:(UIGestureRecognizer *)sender
{
    if (!self.soul)
    {
        self.soul = true;
        self.soulCurId = 0;
    }
    RecentSet *rec = [RecentSet singleton];
    NSMutableArray *list = [rec list];
    if (self.soulCurId + 1 < [rec count])
    {
        [self loadArticle:list[self.soulCurId + 1]];
        self.soulCurId += 1;
    }
}

- (void)goForward:(UIGestureRecognizer *)sender
{
    if (!self.soul)
    {
        self.soul = true;
        self.soulCurId = 0;
    }
    RecentSet *rec = [RecentSet singleton];
    NSMutableArray *list = [rec list];
    if (self.soulCurId - 1 > 0)
    {
        [self loadArticle:list[self.soulCurId - 1]];
        self.soulCurId -= 1;
    }
}

- (void)handleLoadArticle:(NSNotification *)note
{
    [self loadArticle:note.userInfo[@"title"]];
}

- (void)loadArticle:(NSString *)title
{
    if (self.soul)
    {
        RecentSet *rec = [RecentSet singleton];
        [rec add:title];
    }

    self.title = title;
    
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

- (void)searchBarSearchButtonClicked:(UISearchBar *) searchBar
{
    self.soul = false;
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

- (void)favoriteClicked:(UIButton *)sender
{
    FavoriteSet *favs = [FavoriteSet singleton];
    if ([favs exist:self.title]) {
        [favs remove:self.title];
    }
    else {
        [favs add:self.title];
    }
}

@end
