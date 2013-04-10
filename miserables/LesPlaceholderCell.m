//
//  LesPlaceholderCell.m
//  miserables
//
//  Created by Xhacker on 2013-04-08.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesPlaceholderCell.h"

NSInteger const kPlaceholderNth = 4;

@implementation LesPlaceholderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
