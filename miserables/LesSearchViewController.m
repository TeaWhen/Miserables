//
//  LesSearchViewController.m
//  miserables
//
//  Created by Xhacker on 2013-03-15.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesSearchViewController.h"
#import "LesViewController.h"
#import "LesNavigationController.h"
#import "FMResultSet.h"

@interface LesSearchViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@property (weak, nonatomic) LesViewController *parent;
@property (weak, nonatomic) LesNavigationController *nav;

@end

@implementation LesSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nav = (LesNavigationController *)(self.presentingViewController);
    self.parent = [self.nav.viewControllers objectAtIndex:0];
	
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar*) searchBar
{
    NSString *title = [self.searchBar text];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"miserables://%@", [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.parent.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBarCancelButtonClicked:(UISearchBar*) searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(searchText);
    FMResultSet *articles = [self.nav.db executeQuery:@"SELECT * FROM Article WHERE title LIKE ?", [NSString stringWithFormat:@"%@%%", searchText]];
    while ([articles next]) {
        NSString *title = [articles stringForColumn:@"title"];
        //        NSString *content = [articles stringForColumn:@"content"];
        NSLog(@" -> %@", title);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
