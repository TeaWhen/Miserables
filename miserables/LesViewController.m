//
//  LesViewController.m
//  Miserables
//
//  Created by Xhacker on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesViewController.h"

@interface LesViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *navigationBar;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapNavigation;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tapNavigation = [self.tapNavigation initWithTarget:self action: @selector(navigationBarClicked:)];
    self.tapNavigation.numberOfTapsRequired = 2;
    [self.navigationBar addGestureRecognizer:self.tapNavigation];
    NSLog(@"miao");
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
    NSLog(@"miaomiao");
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *) searchBar
{
    
}

- (void) searchBarCancelButtonClicked:(UISearchBar*) searchBar
{
    NSLog(@"searchBarCancelButtonClicked");
    [self.searchBar setHidden:YES];
    [self.searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(id)sender
{
    NSLog(@"Search");
}

@end
