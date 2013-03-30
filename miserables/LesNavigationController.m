//
//  LesNavigationController.m
//  miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-11.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesNavigationController.h"

@interface LesNavigationController ()

@property (strong, nonatomic) NSString *dbPath;

@end

@implementation LesNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self->downloaded = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
