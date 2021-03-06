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
#import "MBProgressHUD.h"

NSString * const kLesLoadArticleNotification = @"LesLoadArticle";
NSString * const kLesReloadArticleNotification = @"LesReloadArticle";

@interface LesViewController () <UIWebViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *title;
@property NSString *searchTerm;
@property bool soul;
@property int soulCurId;

- (void)loadArticle:(NSString *)title;
- (void)handleLoadArticle:(NSNotification *)note;
- (void)handleReloadArticle:(NSNotification *)note;
- (void)setSearchIconToFavorites;

@end

@implementation LesViewController

static NSOperationQueue *queue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadArticle:) name:kLesLoadArticleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadArticle:) name:kLesReloadArticleNotification object:nil];
    
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
    NSLog(@"goBack");
    RecentSet *rec = [RecentSet singleton];
    NSMutableArray *list = [rec list];
    if (self.soulCurId + 1 <= [rec count]) {
        if (!self.soul) {
            self.soul = true;
            self.soulCurId = 0;
        }
        [self loadArticle:list[self.soulCurId + 1]];
        self.soulCurId += 1;
    }
}

- (void)goForward:(UIGestureRecognizer *)sender
{
    NSLog(@"goForward");
    RecentSet *rec = [RecentSet singleton];
    NSMutableArray *list = [rec list];
    if (self.soulCurId - 1 >= 0) {
        if (!self.soul) {
            self.soul = true;
            self.soulCurId = 0;
        }
        [self loadArticle:list[self.soulCurId - 1]];
        self.soulCurId -= 1;
    }
}

- (void)handleLoadArticle:(NSNotification *)note
{
    [self.searchBar resignFirstResponder];
    self.tableView.hidden = YES;
    self.tableView.scrollsToTop = NO;
    self.webView.scrollView.scrollsToTop = YES;
    
    self.soul = false;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"Loading";

    [hud showAnimated:YES whileExecutingBlock:^{
        [self loadArticle:note.userInfo[@"title"]];
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

- (void)handleReloadArticle:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLesLoadArticleNotification object:self userInfo:@{@"title": self.title}];
}

- (void)loadArticle:(NSString *)title
{
    if (!self.soul) {
        if ([title isEqualToString:@"Main Page"]) {
            ;
        }
        else {
            RecentSet *rec = [RecentSet singleton];
            if (![rec exist:title])
            {
                [rec add:title];
            }
            else {
                [rec remove:title];
                [rec add:title];
            }
        }
    }
    else {
        self.soulCurId = 0;
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
        RecentSet *rec = [RecentSet singleton];
        [rec remove:title];
        html_body = @"No entry found.";
    }
    
    NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", html_head, html_body];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        NSString *urlString = url.absoluteString;
        if ([urlString rangeOfString:@"#"].location != NSNotFound) {
            // string contains #
            return YES;
        }
        NSString *title = [urlString componentsSeparatedByString:@"/"].lastObject;
        [self loadArticle:title];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // disable horizontal scrolling
    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.tableView.hidden = NO;
    self.tableView.scrollsToTop = YES;
    self.webView.scrollView.scrollsToTop = NO;
    [self searchBar:self.searchBar textDidChange:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText isEqualToString:self.searchTerm]) {
        self.searchTerm = searchText;
        [ArticleSet singleton].searchTerm = searchText;
        [self.tableView reloadData];
        [self.tableView setContentOffset:CGPointZero];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [self performSegueWithIdentifier:@"tabs" sender:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *title = [self.searchBar text];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLesLoadArticleNotification object:self userInfo:@{@"title": title}];
    [searchBar resignFirstResponder];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[ArticleSet singleton] countForSearch];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
	cell.textLabel.text = [[ArticleSet singleton] resultAtRow:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLesLoadArticleNotification object:self userInfo:@{@"title": title}];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        [self.searchBar resignFirstResponder];
    }
}

@end
