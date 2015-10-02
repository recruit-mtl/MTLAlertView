//
//  MTLAppDelegate.m
//  MTLAlertView
//
//  Created by kasajei on 08/21/2015.
//  Copyright (c) 2015 kasajei. All rights reserved.
//

#import "MTLAppDelegate.h"
#import "MTLAlertView.h"
#import "MTLAlertButton.h"

@implementation MTLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // MTLAlertView
    [MTLAlertView appearance].backgroundImageResizableInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [MTLAlertView appearance].titleFont = [UIFont boldSystemFontOfSize:19.0f];
    [MTLAlertView appearance].messageFont = [UIFont boldSystemFontOfSize:14.0f];
    [MTLAlertView appearance].messageMaximumHeight = 400.f;
    [MTLAlertView appearance].titleAlign = NSTextAlignmentCenter;
    [MTLAlertView appearance].messageAlign = NSTextAlignmentCenter;
    
    // MTLAlertButton
    [MTLAlertButton appearance].normalButtonFontColor = [UIColor whiteColor];
    [MTLAlertButton appearance].cancelButtonFontColor = [UIColor grayColor];
    [MTLAlertButton appearance].normalButtonFont = [UIFont boldSystemFontOfSize:14.f];
    [MTLAlertButton appearance].cancelButtonFont = [UIFont boldSystemFontOfSize:14.f];
    [MTLAlertButton appearance].imageResizableInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);

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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
