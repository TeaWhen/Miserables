//
//  LesRecentsDelegate.m
//  miserables
//
//  Created by Xhacker on 2013-03-30.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesRecentsDelegate.h"

@interface LesRecentsDelegate () <UITableViewDataSource, UITableViewDelegate>

@end


@implementation LesRecentsDelegate

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
	cell.textLabel.text = @"meow";
    return cell;
}


@end
