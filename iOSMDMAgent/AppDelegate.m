//
//  AppDelegate.m
//  iOSMDMAgent
//

#import "AppDelegate.h"
#import "MDMUtils.h"
#import "ConnectionUtils.h"
#import "ConnectionUtils.h"
#import "URLUtils.h"
#import <MediaPlayer/MediaPlayer.h>

#define systemSoundID    1154

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"App is starting...");

    _connectionUtils = [[ConnectionUtils alloc] init];
    _connectionUtils.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    NSLog(@"Authorizing location service");
    [self authorizeLocationService];
    
    NSString *enrollURL = [URLUtils getEnrollmentURLFromPlist];
    NSString *serverURL = [URLUtils getServerURLFromPlist];
    if(enrollURL && ![@"" isEqualToString:enrollURL] && serverURL && ![@"" isEqualToString:serverURL]) {
        NSLog(@"Reading server url from plist");
        [URLUtils saveServerURL:serverURL];
        [URLUtils saveEnrollmentURL:enrollURL];
    }
 
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[MDMUtils getEnrollStatus] isEqualToString:ENROLLED]) {
        [self showUnregisterViewController];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    NSDictionary *apsDictionary = [userInfo objectForKey:APS];
    NSDictionary *extraDictionary = [userInfo objectForKey:EXTRA];
    NSString *udid = [MDMUtils getDeviceUDID];
    NSLog(@"Notification recieved to device: %@", udid);
    
    if (apsDictionary) {
        if (extraDictionary && [extraDictionary isKindOfClass:[NSDictionary class]]) {
            
            NSString *operation = [extraDictionary objectForKey:OPERATION];
            NSString *operationId = [extraDictionary objectForKey:OPERATION_ID];
            
            NSLog(@"Received operation: %@", operation);
            NSLog(@"Operation id: %@", operationId);
            
            if ([@"RING" isEqualToString:operation]) {
                [self triggerAlert];
                ConnectionUtils *connectionUtils = [[ConnectionUtils alloc] init];
                connectionUtils.delegate = self;
                [connectionUtils sendOperationUpdateToServer:udid operationId:operationId status:@"COMPLETED"];
                
            } else if([@"DEVICE_LOCATION" isEqualToString:operation]) {
                [self initLocation];
                [MDMUtils setLocationOperationId:operationId];
            }
        }
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {

    NSLog(@"Sending push token to the server");
    //Check if the UDID is stored
    NSString *udid = [MDMUtils getDeviceUDID];
    
    if (udid) {
        //Device is register in the server
        NSString *token = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:ENCLOSING_TAGS]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (token) {
            
            NSLog(@"Device Token: %@", token);
            
            NSString *oldToken = [MDMUtils getDeviceUDID];
            if (!oldToken || ![oldToken isEqualToString:token]) {

                //push the token to the server
                [_connectionUtils sendPushTokenToServer:udid pushToken:token];
            }
        }
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"handleOpenURL:Decoding URL");
    NSString *accessToken;
    NSString *refreshToken;
    NSString *clientCredentials;
    NSString *tenantDomain;
    NSString *isRefreshComplete;

    NSArray *queryParams = [[url query] componentsSeparatedByString:@"&"];
    for (int i=0; i< [queryParams count]; i++){
        NSArray *keyValue = [queryParams[i] componentsSeparatedByString:@"="];
        NSString *key = keyValue[0];
        NSString *value = keyValue[1];
        if([key isEqualToString:@"accessToken"]){
            accessToken = value;
        }
        else if([key isEqualToString:@"refreshToken"]){
            refreshToken = value;
        }
        else if([key isEqualToString:@"clientCredentials"]){
            clientCredentials = value;
        }
        else if ([key isEqualToString:@"tenantDomain"]) {
            tenantDomain = value;
        }
        else if ([key isEqualToString:@"isRefreshComplete"]) {
            isRefreshComplete = value;
        }
    }
    

    [MDMUtils savePreferance:ACCESS_TOKEN value:accessToken];
    [MDMUtils savePreferance:REFRESH_TOKEN value:refreshToken];
    [MDMUtils savePreferance:CLIENT_CREDENTIALS value:clientCredentials];

    if (!isRefreshComplete) {
        NSLog(@"New enrollment");
        NSString *udid = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [MDMUtils saveDeviceUDID:udid];
        [self registerForPushToken];
        [MDMUtils setEnrollStatus:ENROLLED];
        NSLog(@"handleOpenURL:Enforcing effective policy");
        ConnectionUtils *connectionUtils = [[ConnectionUtils alloc] init];
        connectionUtils.delegate = self;
        [connectionUtils enforceEffectivePolicy:[MDMUtils getDeviceUDID]];
    }
    return YES;
}

- (void)showLoginViewController {    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    loginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [top presentViewController:loginViewController animated:NO completion:nil];
}

- (void)showUnregisterViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *unregisterViewController = [storyboard instantiateViewControllerWithIdentifier:@"viewController"];
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    unregisterViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [top presentViewController:unregisterViewController animated:NO completion:nil];
}

- (void) registerForPushToken {
    
    NSLog(@"Registering for push token");
    
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    } else {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"User has changed location authorization. Requesting authorization");
        [self authorizeLocationService];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Service Authorization"
                                                            message:@"Turn on location services and let the app find device's location"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Turn on location services", nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)initLocation {
    NSLog(@"Initializing location manager");
//    __block UIBackgroundTaskIdentifier bgTask =0;
//    UIApplication  *application = [UIApplication sharedApplication];
//    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
//        [self.locationManager startUpdatingLocation];
//    }];
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Calling didFailWithError %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"Sending location updates to the server");
    NSString *udid = [MDMUtils getDeviceUDID];
    CLLocation *location = [locations lastObject];
    
    if (location && udid) {
        [_connectionUtils sendLocationToServer:udid latitiude:location.coordinate.latitude longitude:location.coordinate.longitude];
    }    
    [self.locationManager stopUpdatingLocation];
    
}

- (void)triggerAlert {
    //initializing sound files
    NSLog(@"Start ringing the device");
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:SOUND_FILE_NAME ofType:SOUND_FILE_EXTENSION];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    
    /**
     * iOS does not natively provide a way to update volume of a devices without users consent.
     * Since MPMusicPlayerController.volume is depricated, we have to use the following
     * work around, where we create a volume slider and adjust the volume.
     */
    MPVolumeView* mpVolumeView = [[MPVolumeView alloc] init];
    UISlider* volumeSlider = nil;
    for (UIView *view in [mpVolumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeSlider = (UISlider*)view;
            break;
        }
    }
    [volumeSlider setValue:1.0f animated:YES];
    [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];

    NSError *error = nil;
    self.theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self.theAudio play];

}

- (void)authorizeLocationService {
    switch (CLLocationManager.authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Location authorization status: not determined");
            [self.locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location authorization status: restricted");
            [self.locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusDenied:
            NSLog(@"Location authorization status: denied");
            [self.locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Location authorization status: authorized when in use");
            [self.locationManager requestAlwaysAuthorization];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"Location authorization status: authorized always");
            // Nothing to do here
            break;
    }
}

@end
