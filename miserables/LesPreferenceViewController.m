//
//  LesPreferenceViewController.m
//  miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-10.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesPreferenceViewController.h"
#import "LesNavigationController.h"
#import "AFDownloadRequestOperation.h"
#import "AFHTTPRequestOperation.h"

@interface LesPreferenceViewController () <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *preferenceTableView;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadProgressCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cancelCell;

@property (weak, nonatomic) LesNavigationController *nav;

@end

@implementation LesPreferenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preferenceTableView.delegate = self;

    self.nav = [LesNavigationController cast:self.navigationController];
    
    if (self.nav->downloaded) {
        self.downloadLabel.text = @"已更新";
        self.downloadLabel.enabled = NO;
        self.downloadCell.userInteractionEnabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 2) {
                // Update button clicked
                NSLog(@"Update clicked.");
                
                self.downloadLabel.text = @"连接中…";
                self.downloadLabel.enabled = NO;
                self.downloadCell.userInteractionEnabled = NO;
                
                id documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSString *currentLibraryPath = [documentDirectory stringByAppendingPathComponent:@"article_new.db"];
                NSString *newLibraryPath = [documentDirectory stringByAppendingPathComponent:@"article_new.db"];
                
                if (!self.nav.downloadOperation) {
                    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mirrors.lifetoy.org/debian/pool/main/i/iceweasel/iceweasel_10.0.12esr-1_amd64.deb"]];
                    self.nav.downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:req targetPath:newLibraryPath shouldResume:YES];
                    self.nav.downloadOperation.shouldOverwrite = YES;
                }
                
                [self.nav.downloadOperation start];
                
                [self.nav.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    self.downloadLabel.text = @"已更新";
                    [self.tableView reloadData];
                    [self.downloadProgressCell setHidden:YES];
                    [self.cancelCell setHidden:YES];
                    self.nav->downloaded = YES;
                    NSLog(@"Successfully downloaded file to %@", newLibraryPath);
                    
                    NSFileManager *fm = [NSFileManager defaultManager];
                    [fm removeItemAtPath:currentLibraryPath error:nil];
                    [fm moveItemAtPath:newLibraryPath toPath:currentLibraryPath error:nil];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    // TODO
                    NSLog(@"Error occured: %@", error);
                    [self.nav.downloadOperation deleteTempFileWithError:nil];
                    self.nav.downloadOperation = nil;
                    
                    // Display a HUD
                    
                    self.downloadLabel.text = @"立即更新";
                    [self.downloadProgressCell setHidden:YES];
                    [self.cancelCell setHidden:YES];
                    [self.tableView reloadData];
                    self.downloadLabel.enabled = YES;
                    self.downloadCell.userInteractionEnabled = YES;
                }];
                
                [self.nav.downloadOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
                    self.downloadLabel.text = @"下载中…";
                    [self.tableView reloadData];
                    [self.downloadProgressCell setHidden:NO];
                    [self.cancelCell setHidden:NO];
                    self.downloadLabel.enabled = NO;
                    self.downloadCell.userInteractionEnabled = NO;
                    
                    float progress = totalBytesReadForFile / (float)totalBytesExpectedToReadForFile;
                    [self.downloadProgressView setProgress:progress];
                    NSLog(@"%lld / %lld", totalBytesReadForFile, totalBytesExpectedToReadForFile);
                }];
            }
            break;
        case 1:
            // 
            if (indexPath.row == 1) {
                // Cancel button clicked
                NSLog(@"Cancel clicked.");
                [self.nav.downloadOperation cancel];
                self.nav.downloadOperation = nil;
                
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
