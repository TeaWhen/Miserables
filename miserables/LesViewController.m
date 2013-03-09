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
    
    [self.db executeUpdate:@"create table Article (title text, content text)"];
    
    NSString *sql = @"insert into Article (title, content) values (?, ?)";
    [self.db executeUpdate:sql, @("我爱北京天安门"), @("天安门上太阳升")];
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
    
    FMResultSet *articles = [self.db executeQuery:@"select * from Article where title = ?", [self.searchBar text]];
    [articles next];
    NSString *content = [articles stringForColumn:@"content"];
    
    NSMutableString *html = [NSMutableString stringWithString:@"<html><head><style type=\"text/css\">"];
    [html appendString:@"body {font-size: px;} "];
    [html appendString:@"</style></head><body><h1>"];
    [html appendString:[self.searchBar text]];
    [html appendString:[NSString stringWithFormat:@"</h1><h2>%@</h2></body></html>", content]];
    
    [self.webView loadHTMLString:html baseURL:url];
    [self.searchBar setHidden:YES];
    self.navigationBar.topItem.title = [self.searchBar text];
    [self.searchBar resignFirstResponder];
    [self.webView becomeFirstResponder];
}

@end
