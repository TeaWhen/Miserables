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
@property UIActivityIndicatorView *progressIndicator;

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
    
    self.downloader = [LesDownloader singleton];
    self.downloader.delegate = self;
    
    if (self.downloader.downloaded) {
        self.downloadLabel.text = @"Already updated";
        self.downloadLabel.enabled = NO;
        self.downloadCell.userInteractionEnabled = NO;
    }
    
    self.progressIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.progressIndicator.center = CGPointMake(self.downloadButton.center.x + 100, self.downloadButton.center.y);
    [self.view addSubview:self.progressIndicator];
    
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
                
                [self.progressIndicator startAnimating];
                
                self.downloadLabel.text = @"Connecting...";
                self.downloadLabel.enabled = NO;
                self.downloadCell.userInteractionEnabled = NO;
                
                [self.downloader start];
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
    
    // reload things
    [self updateArticleCount];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LibraryLastUpdateDate"];
    [self updateUpdateDate];
}

- (void)downloadFailed:(NSError *)error withStatusCode:(NSInteger)statusCode
{
    [self.progressIndicator stopAnimating];
    NSLog(@"Error occured: %@", error);
    
    NSString *message;
    if (statusCode == 404) {
        message = @"Sever error, please contact us.";
    }
    else {
        message = error.localizedDescription;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download failure" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    
    self.downloadLabel.text = @"Update Now";
    [self.downloadProgressCell setHidden:YES];
    [self.cancelCell setHidden:YES];
    [self.tableView reloadData];
    self.downloadLabel.enabled = YES;
    self.downloadCell.userInteractionEnabled = YES;
}

- (void)downloaded:(long long)currentBytes of:(long long)totalBytes
{
    [self.progressIndicator stopAnimating];
    self.downloadLabel.text = @"Downloading...";
    [self.tableView reloadData];
    [self.downloadProgressCell setHidden:NO];
    [self.cancelCell setHidden:NO];
    self.downloadLabel.enabled = NO;
    self.downloadCell.userInteractionEnabled = NO;
    
    float progress = currentBytes / (float)totalBytes;
    [self.downloadProgressView setProgress:progress];
    // NSLog(@"%lld / %lld", currentBytes, totalBytes);
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
