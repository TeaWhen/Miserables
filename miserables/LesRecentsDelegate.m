//
//  LesRecentsDelegate.m
//  miserables
//
//  Created by Xhacker on 2013-03-30.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesRecentsDelegate.h"
#import "RecentsSet.h"

@interface LesRecentsDelegate () <UITableViewDataSource, UITableViewDelegate>

@end


@implementation LesRecentsDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RecentsSet *rec = [RecentsSet singleton];
    return [rec count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    RecentsSet *rec = [RecentsSet singleton];
	cell.textLabel.text = [rec list][indexPath.row];
    return cell;
}

@end
