//
//  LesViewController.m
//  Miserables
//
//  Created by Xhacker on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesViewController.h"
#import "FMResultSet.h"

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
    
    [self openDb];
    
    self.tapNavigation = [self.tapNavigation initWithTarget:self action: @selector(navigationBarClicked:)];
    self.tapNavigation.numberOfTapsRequired = 2;
    [self.navigationBar addGestureRecognizer:self.tapNavigation];
    self.searchBar.delegate = self;
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
        [self.db executeUpdate:sql, @("我爱北京天安门"), @("天安门上太阳升")];
        [self.db executeUpdate:sql, @("闫神"), @("厉害死了！")];
    }
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
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *html_head = @"<link rel='stylesheet' href='Static/css/main.css' type='text/css' />";
    NSString *html_body;

    FMResultSet *articles = [self.db executeQuery:@"SELECT * FROM Article WHERE title = ?", [self.searchBar text]];
    if ([articles next]) {
        NSString *content = [articles stringForColumn:@"content"];
        html_body = [NSString stringWithFormat:@"<h1>%@</h1><p>%@</p></body></html>", [self.searchBar text], content];
    }
    else {
        html_body = @"未找到条目。";
    }
    
    NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body</html>", html_head, html_body];

    [self.webView loadHTMLString:html baseURL:baseURL];
    [self.searchBar setHidden:YES];
    self.navigationBar.topItem.title = [self.searchBar text];
    [self.searchBar resignFirstResponder];
    [self.webView becomeFirstResponder];
}

@end
