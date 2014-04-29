//
//  AppDelegate.m
//  WSO2 Agent
//
//  Created by WSO2 on 10/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <PushDelegate> {
    ApiResponse *_manager;
}
@end

@implementation AppDelegate
@synthesize navController;
@synthesize viewController;
@synthesize unregisterViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    _manager = [[ApiResponse alloc] init];
//    _manager.registerDelegate = self;
//    _manager.responseDelegate = self;
    
    _manager = [[ApiResponse alloc] init];
    _manager.pushDelegate = self;
    
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
    [self registerForPushToken];
    
    [Settings copyResource];
    
    [self showMainWindow];
    
    return YES;
}

- (void)showMainWindow {
    if ([Settings isDeviceRegistered]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            unregisterViewController = [[UnregisterViewController alloc] initWithNibName:@"UnregisterViewController" bundle:nil];
        } else {
            unregisterViewController = [[UnregisterViewController alloc] initWithNibName:@"UnregisterViewController_iPad" bundle:nil];
        }
        navController = [[UINavigationController alloc] initWithRootViewController:unregisterViewController];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            viewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
        } else {
            viewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController_iPad" bundle:nil];
        }
        navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    
    self.navController.navigationBar.barStyle = UIBarStyleBlack;
    self.navController.navigationBar.translucent = NO;
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = navController;
    self.window.autoresizesSubviews = YES;
    [self.window makeKeyAndVisible];
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
    [self showMainWindow];
    
    if([Settings getResourcePlist:PUSH_TOKEN] && [Settings getResourcePlist:DEVICE_UDID]) {
        [_manager sendPushTokenToServer:[Settings getResourcePlist:PUSH_TOKEN] UDID:[Settings getResourcePlist:DEVICE_UDID]];
    }
    
    [self initLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    
//}
//
//- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    
    if (aps) {
        NSString *alert = [aps objectForKey:@"alert"];
    
        if ([@"Device Muted" isEqualToString:alert]) {
            [self muteDevice];
        }
    }
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    //Check if the UDID is stored
    NSString *udid = [Settings getResourcePlist:DEVICE_UDID];
    
    if (udid != NULL) {
        //Device is register in the server
        NSString *token = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (token != NULL) {
            
            NSString *prevToken = [Settings getResourcePlist:PUSH_TOKEN];
            if (![prevToken isEqualToString:token] || ![Settings isPushedToServer]) {
                //Save the new token and push it to the server
                [Settings updatePlist:PUSH_TOKEN StringText:token];
                [Settings updatePlist:PUSHTOKENTOSERVER StringText:@"FALSE"];
                [_manager sendPushTokenToServer:token UDID:udid];
            }
        }
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *udid = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [Settings updatePlist:DEVICE_UDID StringText:udid];
    
    [self registerForPushToken];
    [self initLocation];
    
    return YES;
}


#pragma Delegate Methods
- (void) onSuccessPushToken: (ResponseObject *) responseObject {
    if (responseObject.isSuccess) {
        [Settings updatePlist:PUSHTOKENTOSERVER StringText:@"TRUE"];
    }
}

- (void) connectionError: (ResponseObject *) responseObject {
    //Error Updating Push Token to server
    [Settings updatePlist:PUSHTOKENTOSERVER StringText:@"FALSE"];
}

- (void) registerForPushToken {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)];
}

- (void)muteDevice {
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:0];
}

- (void)initLocation {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 100;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	[_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Calling didFailWithError %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location updated %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [_manager sendLocationToServer:newLocation];
}


@end
