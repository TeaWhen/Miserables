//
//  LesInitialViewController.m
//  miserables
//
//  Created by Yan Zheng on 13-3-15.
//  Copyright (c) 2013年 Eksband. All rights reserved.
//

#import "LesInitialViewController.h"

@interface LesInitialViewController ()

@end

@implementation LesInitialViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self = [super initWithCenterViewController:[storyBoard instantiateViewControllerWithIdentifier:@"navigationController"]
                            leftViewController:[storyBoard instantiateViewControllerWithIdentifier:@"leftViewController"]];
    if (self) {
        // Add any extra init code here
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
