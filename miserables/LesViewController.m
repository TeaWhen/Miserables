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
        NSString *sql = @"insert into Article (title, content) values (?, ?)";
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
    
    FMResultSet *articles = [self.db executeQuery:@"select * from Article where title = ?", [self.searchBar text]];
    [articles next];
    NSString *content = [articles stringForColumn:@"content"];

    NSMutableString *html = [NSMutableString stringWithString:@"<html><head>"];
    [html appendString:@"<link rel=\"stylesheet\" href=\"Resources/css/main.css\" type=\"text/css\" />"];
    [html appendString:@"</head><body><h1>"];
    [html appendString:[self.searchBar text]];
    [html appendString:[NSString stringWithFormat:@"</h1><h2>%@</h2></body></html>", content]];

    [self.webView loadHTMLString:html baseURL:baseURL];
    [self.searchBar setHidden:YES];
    self.navigationBar.topItem.title = [self.searchBar text];
    [self.searchBar resignFirstResponder];
    [self.webView becomeFirstResponder];
}

@end
