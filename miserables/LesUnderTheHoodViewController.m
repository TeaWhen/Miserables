//
//  LesUnderTheHoodViewController.m
//  miserables
//
//  Created by Xhacker on 2013-04-08.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesUnderTheHoodViewController.h"
#import "Cosette.h"

@interface LesUnderTheHoodViewController ()

@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dbVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeContentLabel;
@property (weak, nonatomic) IBOutlet UITextView *libraryTextView;

@end

@implementation LesUnderTheHoodViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[Cosette me] requestVersionWithSuccess:^(id JSON) {
        self.appVersionLabel.text = JSON[@"stable"];
        self.dbVersionLabel.text = JSON[@"db"];
    } failure:^(NSError *error) {
        ;
    }];
    
    [[Cosette me] requestNoticeWithSuccess:^(id JSON) {
        self.noticeTimeLabel.text = JSON[@"time"];
        self.noticeContentLabel.text = JSON[@"content"];
    } failure:^(NSError *error) {
        ;
    }];
    
    [[Cosette me] requestLibrariesWithSuccess:^(id JSON) {
        self.libraryTextView.text = [NSString stringWithFormat:@"%@", JSON];
    } failure:^(NSError *error) {
        ;
    }];

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
