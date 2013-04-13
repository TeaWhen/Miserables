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
#import "QuickDialog.h"
#import "QProgressElement.h"

@interface LesLibraryViewController () <LesDownloaderDelegate>

@property LesDownloader *downloader;
@property QLabelElement *updateDateLabel;
@property QLabelElement *articleCountLabel;
@property QProgressElement *downloadProgress;
@property QButtonElement *updateButton;

- (void)loadDialog;
- (void)updateArticleCount;
- (void)updateUpdateDate;

@end

@implementation LesLibraryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadDialog];
    
    [self updateArticleCount];
    [self updateUpdateDate];
    
    self.downloader = [LesDownloader singleton];
    self.downloader.delegate = self;
}

- (void)loadDialog
{
    QRootElement *root = [[QRootElement alloc] init];
    root.grouped = YES;
    
    QSection *section = [[QSection alloc] init];
    section.footer = @"If the network is slow, you can also use iTunes File Sharing to import the library.";
    self.updateDateLabel = [[QLabelElement alloc] initWithTitle:@"Updated on" Value:@"42 days ago"];
    self.articleCountLabel = [[QLabelElement alloc] initWithTitle:@"Number of Articles" Value:@"31415926"];
    self.downloadProgress = [[QProgressElement alloc] init];
    self.downloadProgress.hidden = YES;
    self.updateButton = [[QButtonElement alloc] initWithTitle:@"Update Now"];
    self.updateButton.controllerAction = @"updateClicked:";
    
    [section addElement:self.updateDateLabel];
    [section addElement:self.articleCountLabel];
    [section addElement:self.downloadProgress];
    [section addElement:self.updateButton];
    
    QSection *creditsSection = [QSection new];
    QButtonElement *creditsButton = [[QButtonElement alloc] initWithTitle:@"Credits"];
    creditsButton.controllerAction = @"creditsClicked:";
    [creditsSection addElement:creditsButton];
    
    [root addSection:section];
    [root addSection:creditsSection];
    
    self.root = root;
    self.quickDialogTableView = [self.quickDialogTableView initWithController:self];
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

- (void)downloadCompleted
{
    self.downloadProgress.hidden = YES;
    self.updateButton.enabled = NO;
    self.updateButton.title = @"Updated";
    [self.quickDialogTableView reloadData];
    
    // reload things
    [[ArticleSet singleton] reload];
    [self updateArticleCount];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LibraryLastUpdateDate"];
    [self updateUpdateDate];
}

- (void)downloadFailed:(NSError *)error withStatusCode:(NSInteger)statusCode
{
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
    self.downloadProgress.progress = progress;
}

- (void)creditsClicked:(id)sender
{
    [self performSegueWithIdentifier:@"credits" sender:self];
}

- (void)updateClicked:(QButtonElement *)sender
{
    [self.downloader cancel];
    [self.downloader start];
    self.downloadProgress.hidden = NO;
    self.updateButton.controllerAction = @"cancelClicked:";
    self.updateButton.title = @"Cancel";
    [self.quickDialogTableView reloadData];
}

- (void)cancelClicked:(QButtonElement *)sender
{
    [self.downloader cancel];
    self.downloadProgress.hidden = YES;
    self.updateButton.controllerAction = @"updateClicked:";
    self.updateButton.title = @"Update Now";
    [self.quickDialogTableView reloadData];
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
