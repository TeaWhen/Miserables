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

@interface LesLibraryViewController () <LesDownloaderDelegate>

@property LesDownloader *downloader;
@property QLabelElement *updateDateLabel;
@property QLabelElement *articleCountLabel;
@property QLabelElement *downloadProgressLabel;

- (void)updateArticleCount;
- (void)updateUpdateDate;

@end

@implementation LesLibraryViewController

- (void)viewWillAppear_:(BOOL)animated
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
    creditsButton.controllerAction = @"creditsClicked:";
    [creditsSection addElement:creditsButton];
    
    [root addSection:section];
    [root addSection:creditsSection];
    
    self.root = root;
    
    // update things
    [self updateArticleCount];
    [self updateUpdateDate];
    
    self.downloader = [LesDownloader singleton];
    self.downloader.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    QRootElement *root = [QRootElement new];
    root.grouped = YES;
    QSection *section = [QSection new];
    section.footer = @"Test Footer";
    QLabelElement *label = [[QLabelElement alloc] initWithTitle:@"Updated on" Value:@"42 days ago"];
    [section addElement:label];
    [root addSection:section];
    self.root = root;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    // reload things
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

- (void)creditsClicked:(id)sender
{
    [self performSegueWithIdentifier:@"credits" sender:self];
}

@end
