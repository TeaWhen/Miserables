//
//  LesFavoritesViewController.m
//  miserables
//
//  Created by Xhacker on 2013-03-18.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesFavoritesViewController.h"
#import "LesViewController.h"
#import "Favorites.h"

@interface LesFavoritesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) LesViewController *parent;
@property (weak, nonatomic) LesNavigationController *nav;
@property NSArray *favorites;

@end

@implementation LesFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Favorites *favs = [[Favorites alloc] init];
    self.favorites = [favs list];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.nav = (LesNavigationController *)(self.presentingViewController);
    self.parent = [self.nav.viewControllers objectAtIndex:0];
}

- (IBAction)doneClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    return self.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
	cell.textLabel.text = [self.favorites objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [self.favorites objectAtIndex:indexPath.row];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"miserables://%@", [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.parent.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
