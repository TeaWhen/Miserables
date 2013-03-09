//
//  LesViewController.m
//  Miserables
//
//  Created by Xhacker on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesViewController.h"

@interface LesViewController ()

@end

@implementation LesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    wikiIndex = [[NSMutableArray alloc] init];
    tapNavigation = [tapNavigation initWithTarget:self action: @selector(navigationBarClicked:)];
    tapNavigation.numberOfTapsRequired = 2;
    [navigationBar addGestureRecognizer: tapNavigation];
    
    searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) navigationBarClicked:(UIPanGestureRecognizer *) tapNavigation
{
    [searchBar setHidden:NO];
    [searchBar becomeFirstResponder];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *) searchBar
{
    
}

- (void) searchBarCancelButtonClicked:(UISearchBar*) searchBar
{
    [searchBar setHidden:YES];
    [searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(id)sender
{
    
}

@end
