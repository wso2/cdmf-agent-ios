//
//  AppDelegate.h
//  WSO2 Agent
//
//  Created by WSO2 on 10/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeViewController.h"
#import "Settings.h"
#import "PushDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PushDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) WelcomeViewController *viewController;
@property (strong, nonatomic) UnregisterViewController *unregisterViewController;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
