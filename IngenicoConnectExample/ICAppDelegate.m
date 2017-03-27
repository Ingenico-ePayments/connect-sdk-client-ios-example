//
//  ICAppDelegate.m
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 15/12/2016.
//  Copyright © 2017 Global Collect Services. All rights reserved.
//

#import "SVProgressHUD.h"

#import <IngenicoConnectExample/ICAppDelegate.h>
#import <IngenicoConnectExample/ICStartViewController.h>

@implementation ICAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Uncomment the following two statement to enable logging of requests and responses
    //[[AFNetworkActivityLogger sharedLogger] startLogging];
    //[[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];

    ICStartViewController *shop = [[ICStartViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:shop];

    self.window.rootViewController = nav;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

@end
