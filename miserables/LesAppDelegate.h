//
//  LesAppDelegate.h
//  miserables
//
//  Created by Yan Zheng on 13-3-2.
//  Copyright (c) 2013年 Eksband. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LesAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
