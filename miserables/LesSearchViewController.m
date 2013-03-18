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

@interface LesSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;

@property (weak, nonatomic) LesViewController *parent;
@property (weak, nonatomic) LesNavigationController *nav;

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

    self.nav = (LesNavigationController *)(self.presentingViewController);
    self.parent = [self.nav.viewControllers objectAtIndex:0];
    
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
    [self.parent.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBarCancelButtonClicked:(UISearchBar*) searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    FMResultSet *articles = [self.nav.db executeQuery:@"SELECT * FROM Article WHERE title LIKE ?", [NSString stringWithFormat:@"%@%%", searchText]];
    [self.result removeAllObjects];
    while ([articles next]) {
        NSString *title = [articles stringForColumn:@"title"];
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
	cell.textLabel.text = [self.result objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [self.result objectAtIndex:indexPath.row];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"miserables://%@", [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.parent.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
