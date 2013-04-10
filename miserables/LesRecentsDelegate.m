//
//  LesRecentsDelegate.m
//  miserables
//
//  Created by Xhacker on 2013-03-30.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesRecentsDelegate.h"
#import "LesPlaceholderCell.h"
#import "RecentSet.h"

@interface LesRecentsDelegate () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation LesRecentsDelegate

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
        return kPlaceholderNth;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell;
    RecentSet *rec = [RecentSet singleton];
    if ([rec count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] init];
        }
        [cell textLabel].text = [rec list][indexPath.row];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Placeholder"];
        if (cell == nil) {
            cell = [[LesPlaceholderCell alloc] init];
        }
        if (indexPath.row + 1 == kPlaceholderNth) {
            [cell label].text = @"No Recents";
        }
        else {
            [cell label].text = @"";
        }
    }
    
    return cell;
}

@end
