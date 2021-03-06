//
//  LesAppDelegate.m
//  Miserables
//
//  Created by Xhacker and Zheng Yan on 2013-03-09.
//  Copyright (c) 2013 Eksband. All rights reserved.
//

#import "LesAppDelegate.h"
#import "FavoriteSet.h"
#import "ArticleSet.h"
#import "RecentSet.h"

@implementation LesAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"59293f0b-a5a2-4d57-9a58-866ab448db1d"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    [[FavoriteSet singleton] close];
    [[ArticleSet singleton] close];
    [[RecentSet singleton] close];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    [[FavoriteSet singleton] open];
    [[ArticleSet singleton] open];
    [[RecentSet singleton] open];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
