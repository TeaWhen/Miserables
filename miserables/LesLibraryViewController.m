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
#import "QRootElement.h"
#import "QRootBuilder.h"

@interface LesLibraryViewController () <UITableViewDelegate, LesDownloaderDelegate>

@property LesDownloader *downloader;
@property UIActivityIndicatorView *progressIndicator;

@property QLabelElement *updateDateLabel;
@property QLabelElement *articleCountLabel;
@property QLabelElement *downloadProgressLabel;

- (void)updateArticleCount;
- (void)updateUpdateDate;

@end

@implementation LesLibraryViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    QRootElement *root = [QRootElement new];
    root.grouped = YES;
    
    QSection *section = [QSection new];
    section.footer = @"If the network is slow, you can also use iTunes File Sharing to import the library.";
    self.updateDateLabel = [[QLabelElement alloc] initWithTitle:@"Updated on" Value:@"42 days ago"];
    self.articleCountLabel = [[QLabelElement alloc] initWithTitle:@"Number of Articles" Value:@"31415926"];
    self.downloadProgressLabel = [[QLabelElement alloc] initWithTitle:@"Downloaded" Value:@"0%"];
    QButtonElement *updateButton = [[QButtonElement alloc] initWithTitle:@"Update Now"];
    
    [section addElement:self.updateDateLabel];
    [section addElement:self.articleCountLabel];
    [section addElement:updateButton];
    
    QSection *creditsSection = [QSection new];
    QButtonElement *creditsButton = [[QButtonElement alloc] initWithTitle:@"Credits"];
    [creditsSection addElement:creditsButton];
    
    [root addSection:section];
    [root addSection:creditsSection];
    
    self.root = root;
}

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
    }
    
    self.progressIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.progressIndicator];
    
    // update things
    [self updateArticleCount];
    [self updateUpdateDate];
}

- (void)updateArticleCount
{
    ArticleSet *articles = [ArticleSet singleton];
    self.articleCountLabel.value = [NSString stringWithFormat:@"%d", [articles count]];
}

- (void)updateUpdateDate
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDate *updateDate = [defaults objectForKey:@"LibraryLastUpdateDate"];
    if (updateDate) {
        self.updateDateLabel.value = [updateDate prettyDate];
    }
    else {
        self.updateDateLabel.value = @"Never update";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 2) {
                // update button clicked
                NSLog(@"Update clicked.");
                
                [self.downloader start];
            }
            break;
        case 1:
            if (indexPath.row == 1) {
                // cancel button clicked
                NSLog(@"Cancel clicked.");
                [self.downloader cancel];
            }
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)downloadCompleted
{    
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
}

- (void)downloaded:(long long)currentBytes of:(long long)totalBytes
{
    float progress = currentBytes / (float)totalBytes;
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
