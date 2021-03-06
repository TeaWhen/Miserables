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

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property FavoriteSet *favoriteSet;
@property BOOL shouldDisplayPlaceholder;

@end

@implementation LesFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.favoriteSet = [FavoriteSet singleton];
    if ([self.favoriteSet count]) {
        self.shouldDisplayPlaceholder = NO;
    }
    else {
        self.shouldDisplayPlaceholder = YES;
    }
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
    if (self.shouldDisplayPlaceholder) {
        self.editButton.enabled = NO;
        // placeholder cell
        return 4;
    }
    else {
        self.editButton.enabled = YES;
        return [self.favoriteSet count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell;
    if ([self.favoriteSet count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        [cell textLabel].text = [self.favoriteSet list][indexPath.row];
    }
    else {
        // 4th is placeholder
        if (indexPath.row + 1 == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Placeholder"];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            [cell textLabel].text = @"";
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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

- (void)editClicked:(UIBarButtonItem *)sender
{
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
