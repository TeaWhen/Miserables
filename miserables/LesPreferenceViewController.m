//
//  LesPreferenceViewController.m
//  miserables
//
//  Created by Xhacker on 2013-03-10.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesPreferenceViewController.h"
#import "AFDownloadRequestOperation.h"
#import "AFHTTPRequestOperation.h"

@interface LesPreferenceViewController () <UITableViewDelegate, NSURLConnectionDelegate, NSURLConnectionDownloadDelegate>

@property (strong, nonatomic) IBOutlet UITableView *preferenceTableView;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadProgressCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cancelCell;

@property (strong, nonatomic) AFDownloadRequestOperation *downloadOperation;

@end

@implementation LesPreferenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preferenceTableView.delegate = self;
    
    __weak typeof(self) weak_self = self;
    id documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *libraryPath = [documentDirectory stringByAppendingPathComponent:@"article.db"];
    
    if (!self.downloadOperation) {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://media.animusic2.com.s3.amazonaws.com/Animusic-ResonantChamber480p.mov"]];
        self.downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:req targetPath:libraryPath shouldResume:YES];
        NSLog(@"miaow");
    }
    
    [self.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        weak_self.downloadLabel.text = @"已更新";
        [weak_self.downloadProgressCell setHidden:YES];
        [weak_self.cancelCell setHidden:YES];
        NSLog(@"Successfully downloaded file to %@", libraryPath);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [self.downloadOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        weak_self.downloadLabel.text = @"下载中…";
        // change the section title
        [weak_self.tableView reloadData];
        [weak_self.downloadProgressCell setHidden:NO];
        [weak_self.cancelCell setHidden:NO];
        float progress = totalBytesReadForFile / (float)totalBytesExpectedToReadForFile;
        [weak_self.downloadProgressView setProgress:progress];
        NSLog(@"%lld / %lld", totalBytesReadForFile, totalBytesExpectedToReadForFile);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 2) {
                // Update button clicked
                NSLog(@"Update clicked.");
                [self.downloadOperation start];
                
                self.downloadLabel.text = @"连接中…";
                self.downloadLabel.enabled = NO;
                self.downloadCell.userInteractionEnabled = NO;
            }
            break;
        case 1:
            // 
            if (indexPath.row == 1) {
                // Cancel button clicked
                [self.downloadOperation cancel];
                self.downloadLabel.text = @"立即更新";
                [self.downloadProgressCell setHidden:YES];
                [self.cancelCell setHidden:YES];
                [self.tableView reloadData];
                self.downloadLabel.enabled = YES;
                self.downloadCell.userInteractionEnabled = YES;
            }
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"资料库";
    }
    else if (section == 1) {
        if (self.downloadProgressCell.hidden) {
            return @"";
        }
        else {
            return @"下载进度";
        }
    }
    
    return @"";
}

- (void)viewDidDisappear
{
    [self.downloadOperation cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
