//
//  LesUnderTheHoodViewController.m
//  miserables
//
//  Created by Xhacker on 2013-04-08.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesUnderTheHoodViewController.h"

@interface LesUnderTheHoodViewController ()

@end

@implementation LesUnderTheHoodViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
