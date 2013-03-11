//
//  LesPreferenceViewController.m
//  miserables
//
//  Created by Xhacker on 2013-03-10.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesPreferenceViewController.h"

@interface LesPreferenceViewController () <UITableViewDelegate, NSURLConnectionDownloadDelegate>

@property (strong, nonatomic) IBOutlet UITableView *preferenceTableView;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadCell;

@end

@implementation LesPreferenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preferenceTableView.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 2) {
                NSLog(@"Download clicked.");
                NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://goagentx.googlecode.com/files/GoAgentX-v1.3.14.dmg"]];
                [NSURLConnection connectionWithRequest:req delegate:self];
                
                self.downloadLabel.text = @"连接中…";
                self.downloadLabel.enabled = NO;
                self.downloadCell.userInteractionEnabled = NO;
            }
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    self.downloadLabel.text = @"下载中…";
    [self.downloadProgressView setHidden:NO];
    [self.downloadProgressView setProgress:(float)totalBytesWritten / expectedTotalBytes];
    NSLog(@"%lld / %lld", totalBytesWritten, expectedTotalBytes);
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    self.downloadLabel.text = @"已更新";
    [self.downloadProgressView setHidden:YES];
    NSLog(destinationURL.path);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
