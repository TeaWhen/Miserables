//
//  LesRecentsDelegate.m
//  miserables
//
//  Created by Xhacker on 2013-03-30.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesRecentsViewController.h"
#import "LesViewController.h"
#import "RecentSet.h"

@interface LesRecentsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation LesRecentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RecentSet *rec = [RecentSet singleton];
    if ([rec count]) {
        return [rec count];
    }
    else {
        // placeholder cell
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell;
    RecentSet *rec = [RecentSet singleton];
    if ([rec count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        [cell textLabel].text = [rec list][indexPath.row];
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
    RecentSet *rec = [RecentSet singleton];
    if ([rec count]) {
        NSString *title = [rec list][indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLesLoadArticleNotification object:self userInfo:@{@"title": title}];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)clear
{
    [[RecentSet singleton] removeAll];
    [self.tableView reloadData];
}

@end
