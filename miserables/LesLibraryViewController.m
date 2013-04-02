//
//  LesPreferenceViewController.m
//  miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-10.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesLibraryViewController.h"
#import "FMResultSet.h"
#import "NSDate+PrettyDate.h"
#import "LesViewController.h"
#import "ArticleSet.h"
#import "LesDownloader.h"

@interface LesLibraryViewController () <UITableViewDelegate, LesDownloaderDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleCountLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadProgressCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cancelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *downloadButton;

@property LesDownloader *downloader;

- (void)updateArticleCount;
- (void)updateUpdateDate;

@end

@implementation LesLibraryViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if (self.nav->downloaded) {
//        self.downloadLabel.text = @"Already updated";
//        self.downloadLabel.enabled = NO;
//        self.downloadCell.userInteractionEnabled = NO;
//    }
    
    self.downloader = [LesDownloader singleton];
    
    // update things
    [self updateArticleCount];
    [self updateUpdateDate];
}

- (void)updateArticleCount
{
    ArticleSet *articles = [ArticleSet singleton];
    self.articleCountLabel.text = [NSString stringWithFormat:@"%d", [articles count]];
}

- (void)updateUpdateDate
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate *updateDate = [defaults objectForKey:@"LibraryLastUpdateDate"];
    if (updateDate) {
        self.updateDateLabel.text = [updateDate prettyDate];
    }
    else {
        self.updateDateLabel.text = @"Never update";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 2) {
                // update button clicked
                NSLog(@"Update clicked.");
                
                UIActivityIndicatorView *progressIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                progressIndicator.center = CGPointMake(self.downloadButton.center.x + 100, self.downloadButton.center.y);
                [self.view addSubview:progressIndicator];
                [progressIndicator startAnimating];
                
                self.downloadLabel.text = @"Connecting...";
                self.downloadLabel.enabled = NO;
                self.downloadCell.userInteractionEnabled = NO;
                
                [self.downloader start];
                
//                [self.nav.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    [progressIndicator stopAnimating];
//                    NSLog(@"Error occured: %@", error);
//                    [self.nav.downloadOperation deleteTempFileWithError:nil];
//                    self.nav.downloadOperation = nil;
//                    
//                    NSString *message;
//                    if ([operation.response statusCode] == 404) {
//                        message = @"Server error, please contact us";
//                    }
//                    else {
//                        message = error.localizedDescription;
//                    }
//                    
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download failure" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//                    [alert show];
//                    
//                    self.downloadLabel.text = @"Update Now";
//                    [self.downloadProgressCell setHidden:YES];
//                    [self.cancelCell setHidden:YES];
//                    [self.preferenceTableView reloadData];
//                    self.downloadLabel.enabled = YES;
//                    self.downloadCell.userInteractionEnabled = YES;
//                }];
//                
//                [self.nav.downloadOperation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
//                    [progressIndicator stopAnimating];
//                    self.downloadLabel.text = @"Downloading...";
//                    [self.preferenceTableView reloadData];
//                    [self.downloadProgressCell setHidden:NO];
//                    [self.cancelCell setHidden:NO];
//                    self.downloadLabel.enabled = NO;
//                    self.downloadCell.userInteractionEnabled = NO;
//                    
//                    float progress = totalBytesReadForFile / (float)totalBytesExpectedToReadForFile;
//                    [self.downloadProgressView setProgress:progress];
//                    // NSLog(@"%lld / %lld", totalBytesReadForFile, totalBytesExpectedToReadForFile);
//                }];
            }
            break;
        case 1:
            if (indexPath.row == 1) {
                // cancel button clicked
                NSLog(@"Cancel clicked.");
                [self.downloader cancel];
                
                self.downloadLabel.text = @"Update Now";
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
    if (section == 1) {
        if (self.downloadProgressCell.hidden) {
            return @"";
        }
        else {
            return @"Download progress";
        }
    }
    
    return @"";
}

- (void)downloadCompleted
{
    self.downloadLabel.text = @"Already updated";
    [self.tableView reloadData];
    [self.downloadProgressCell setHidden:YES];
    [self.cancelCell setHidden:YES];
//    NSLog(@"Successfully downloaded file to %@", newLibraryPath);
    
//    NSFileManager *fm = [NSFileManager defaultManager];
//    [fm removeItemAtPath:currentLibraryPath error:nil];
//    [fm moveItemAtPath:newLibraryPath toPath:currentLibraryPath error:nil];
    
    // reload things
    [self updateArticleCount];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LibraryLastUpdateDate"];
    [self updateUpdateDate];
}

- (void)downloadFailed:(NSError *)error
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // TODO: if main view is displaying main page, reload it.
}

@end
