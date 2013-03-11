//
//  LesPreferenceViewController.m
//  miserables
//
//  Created by Xhacker on 2013-03-10.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesPreferenceViewController.h"

@interface LesPreferenceViewController () <UITableViewDelegate, NSURLConnectionDelegate, NSURLConnectionDownloadDelegate>

@property (strong, nonatomic) IBOutlet UITableView *preferenceTableView;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadProgressCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cancelCell;

@property (strong, nonatomic) NSURLConnection *downloadConn;

@end

@implementation LesPreferenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.preferenceTableView.delegate = self;
    
    if (!self.downloadConn) {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://goagentx.googlecode.com/files/GoAgentX-v1.3.14.dmg"]];
        self.downloadConn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 2) {
                // Update button clicked
                NSLog(@"Update clicked.");
                [self.downloadConn start];
                
                self.downloadLabel.text = @"连接中…";
                self.downloadLabel.enabled = NO;
                self.downloadCell.userInteractionEnabled = NO;
            }
            break;
        case 1:
            // 
            if (indexPath.row == 1) {
                // Cancel button clicked
                
            }
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    self.downloadLabel.text = @"下载中…";
    // change the section title
    [self.tableView reloadData];
    [self.downloadProgressCell setHidden:NO];
    [self.cancelCell setHidden:NO];
    [self.downloadProgressView setProgress:(float)totalBytesWritten / expectedTotalBytes];
    NSLog(@"%lld / %lld", totalBytesWritten, expectedTotalBytes);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Failed");
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    self.downloadLabel.text = @"已更新";
    [self.downloadProgressCell setHidden:YES];
    [self.cancelCell setHidden:YES];
    NSLog(@"%@", destinationURL.path);
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
