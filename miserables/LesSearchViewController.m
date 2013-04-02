//
//  LesSearchViewController.m
//  miserables
//
//  Created by Xhacker on 2013-03-15.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesSearchViewController.h"
#import "LesViewController.h"
#import "FMResultSet.h"
#import "ArticleSet.h"

@interface LesSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@property (strong, nonatomic) NSMutableArray *result;

@end

@implementation LesSearchViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.result = [[NSMutableArray alloc] init];
	
    self.searchBar.delegate = self;
    self.resultTableView.dataSource = self;
    
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
    
    [self searchBar:self.searchBar textDidChange:@""];
}

- (void) searchBarSearchButtonClicked:(UISearchBar*) searchBar
{
    NSString *title = [self.searchBar text];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"miserables://%@", [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//    [self.parent.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBarCancelButtonClicked:(UISearchBar*) searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.result removeAllObjects];
    ArticleSet *articles = [ArticleSet singleton];
    for (NSString *title in [articles articlesByKeyword:searchText]) {
        [self.result addObject:title];
    }
    [self.resultTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.result.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
	cell.textLabel.text = self.result[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.result[indexPath.row];
//    [self.parent loadArticle:title];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
