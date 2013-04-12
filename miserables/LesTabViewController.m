//
//  LesTabViewController.m
//  miserables
//
//  Created by Xhacker on 2013-04-11.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesTabViewController.h"
#import "LesFavoritesViewController.h"
#import "LesRecentsViewController.h"
#import "LesLibraryViewController.h"

@interface LesTabViewController ()

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property LesFavoritesViewController *favoritesVC;
@property LesRecentsViewController *recentsVC;
@property LesLibraryViewController *libraryVC;
@property UIViewController *currentVC;
@property UIBarButtonItem *editButton;
@property UIBarButtonItem *clearButton;
@property UIBarButtonItem *spaceItem;

@end

@implementation LesTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.favoritesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"favorites"];
    [self addChildViewController:self.favoritesVC];
    
    self.recentsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"recents"];
    [self addChildViewController:self.recentsVC];
    
    self.libraryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"library"];
    [self addChildViewController:self.libraryVC];
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:nil];
    self.clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    NSMutableArray *items = [self.toolbar.items mutableCopy];
    [items insertObject:self.spaceItem atIndex:0];
    self.toolbar.items = items;
    
    [self segmentChanged:self.segmentedControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

enum {
    FavoritesSeg = 0,
    RecentsSeg,
    LibrarySeg,
};

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    [self.currentVC.view removeFromSuperview];
    if (sender.selectedSegmentIndex == FavoritesSeg) {
        self.title = @"Favorites";
        self.favoritesVC.view.frame = self.container.frame;
        [self.container addSubview:self.favoritesVC.view];
        self.currentVC = self.favoritesVC;
        
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [items removeObjectAtIndex:0];
        [items insertObject:self.editButton atIndex:0];
        self.toolbar.items = items;
    }
    else if (sender.selectedSegmentIndex == RecentsSeg) {
        self.title = @"Recents";
        self.recentsVC.view.frame = self.container.frame;
        [self.container addSubview:self.recentsVC.view];
        self.currentVC = self.recentsVC;
        
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [items removeObjectAtIndex:0];
        [items insertObject:self.clearButton atIndex:0];
        self.toolbar.items = items;
}
    else if (sender.selectedSegmentIndex == LibrarySeg) {
        self.title = @"Library";
        self.libraryVC.view.frame = self.container.frame;
        [self.container addSubview:self.libraryVC.view];
        self.currentVC = self.libraryVC;
        
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [items removeObjectAtIndex:0];
        [items insertObject:self.spaceItem atIndex:0];
        self.toolbar.items = items;
    }
}

- (void)editClicked:(UIBarButtonItem *)sender {
//    if ([self.tableView isEditing]) {
//        [sender setStyle:UIBarButtonItemStyleBordered];
//        sender.title = @"Edit";
//        [self.tableView setEditing:NO animated:YES];
//    }
//    else
//    {
//        [sender setStyle:UIBarButtonItemStyleDone];
//        sender.title = @"Done";
//        [self.tableView setEditing:YES animated:YES];
//    }
}

@end
