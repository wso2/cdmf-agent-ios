//
//  AppDelegate.h
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 2/5/15.
//  Copyright (c) 2015 WSO2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LoginViewController.h"
#import "ConnectionUtils.h"
#import "SDKProtocol.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, SDKProtocol>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (retain, nonatomic) ConnectionUtils *connectionUtils;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) AVAudioPlayer *theAudio;

- (void)showLoginViewController;

@end

