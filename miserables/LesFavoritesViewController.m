//
//  LesFavoritesViewController.m
//  miserables
//
//  Created by Xhacker on 2013-03-18.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesFavoritesViewController.h"
#import "LesViewController.h"
#import "FavoriteSet.h"

@interface LesFavoritesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *favoritesNavigationItem;
@property (weak, nonatomic) LesViewController *parent;
@property (weak, nonatomic) LesNavigationController *nav;
@property FavoriteSet *favoriteSet;

@end

@implementation LesFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.favoriteSet = [[FavoriteSet alloc] init];
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
    return [self.favoriteSet count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
	cell.textLabel.text = [[self.favoriteSet list] objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [[self.favoriteSet list] objectAtIndex:indexPath.row];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"miserables://%@", [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self.parent.webView loadRequest:[NSURLRequest requestWithURL:URL]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Table view editing

- (IBAction)editClicked:(UIBarButtonItem *)sender {
    if ([self.tableView isEditing]) {
        self.favoritesNavigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editClicked:)];
        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        self.favoritesNavigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editClicked:)];
        [self.tableView setEditing:YES animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)
sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger fromRow = [sourceIndexPath row];
    NSUInteger toRow = [destinationIndexPath row];
    
//    id object = [list objectAtIndex:fromRow];
//    [list removeObjectAtIndex:fromRow];
//    [list insertObject:object atIndex:toRow];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Delete row %d.", indexPath.row);
    [self.favoriteSet deleteAtRow:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
