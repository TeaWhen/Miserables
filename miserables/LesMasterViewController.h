//
//  LesMasterViewController.h
//  miserables
//
//  Created by Yan Zheng on 13-3-2.
//  Copyright (c) 2013年 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LesDetailViewController;

#import <CoreData/CoreData.h>

@interface LesMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) LesDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
