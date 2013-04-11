//
//  LesFavoritesViewController.m
//  miserables
//
//  Created by Xhacker on 2013-03-18.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesFavoritesViewController.h"
#import "LesViewController.h"
#import "LesPlaceholderCell.h"
#import "FavoriteSet.h"

@interface LesFavoritesViewController () <UITableViewDataSource, UITableViewDelegate>

@property FavoriteSet *favoriteSet;

@end

@implementation LesFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.favoriteSet = [FavoriteSet singleton];
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
    if ([self.favoriteSet count]) {
        return [self.favoriteSet count];
    }
    else {
        // placeholder cell
        return kPlaceholderNth;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell;
    if ([self.favoriteSet count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] init];
        }
        [cell textLabel].text = [self.favoriteSet list][indexPath.row];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Placeholder"];
        if (cell == nil) {
            cell = [[LesPlaceholderCell alloc] init];
        }
        if (indexPath.row + 1 == kPlaceholderNth) {
            [cell label].text = @"No Favorites";
        }
        else {
            [cell label].text = @"";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.favoriteSet count]) {
        NSString *title = [self.favoriteSet list][indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLesLoadArticleNotification object:self userInfo:@{@"title": title}];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark Table view editing

- (IBAction)editClicked:(UIBarButtonItem *)sender {
    if ([self.tableView isEditing]) {
        [sender setStyle:UIBarButtonItemStyleBordered];
        sender.title = @"Edit";
        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        [sender setStyle:UIBarButtonItemStyleDone];
        sender.title = @"Done";
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
    if (sourceIndexPath == destinationIndexPath) {
        return;
    }
    
    [self.favoriteSet moveRow:sourceIndexPath.row toRow:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Delete row %d.", indexPath.row);
    [self.favoriteSet removeAtRow:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
