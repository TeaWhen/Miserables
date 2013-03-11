//
//  LesNavigationController.m
//  miserables
//
//  Created by Xhacker on 2013-03-11.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesNavigationController.h"

@interface LesNavigationController ()

@end

@implementation LesNavigationController

+ (instancetype)cast:(id)from {
    if ([from isKindOfClass:self]) {
        return from;
    }
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self->downloaded = NO;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
