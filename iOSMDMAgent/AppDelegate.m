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
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface AppDelegate ()

@property (nonatomic, copy) void (^fetchCompletionHandler)(UIBackgroundFetchResult result);

@end

@implementation AppDelegate

NSInteger const LOCATION_OFF_CODE = 1000;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"App is starting...");

    _connectionUtils = [[ConnectionUtils alloc] init];
    _connectionUtils.delegate = self;
    
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

    // Remote configs for the App are pushed by the EMM server and are written to a config space
    // with the key com.apple.configuration.managed.
    static NSString const *managedConfigurations = @"com.apple.configuration.managed";
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:managedConfigurations];
    Boolean depEnabled = [[serverConfig objectForKey:@"depEnabled"] boolValue];
    if (depEnabled && ![[MDMUtils getEnrollStatus] isEqualToString:ENROLLED]) {
        NSLog(@"DEP enabled device.");
        NSString *accessToken = serverConfig[@"accessToken"];
        NSString *refreshToken = serverConfig[@"refreshToken"];
        NSString *clientId = serverConfig[@"clientId"];
        NSString *clientSecret = serverConfig[@"clientSecret"];
        NSString *remoteEnrollmentURL = serverConfig[@"enrollmentURL"];
        NSString *remoteServerURL = serverConfig[@"serverURL"];
        NSString *UDID = serverConfig[@"UDID"];
        NSString *joinCredentials = [NSString stringWithFormat:@"%@:%@", clientId, clientSecret];
        NSData *credentialsData = [joinCredentials dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64EncodedClientCredentials = [credentialsData base64EncodedStringWithOptions:0];
        [MDMUtils savePreferance:CLIENT_CREDENTIALS value:base64EncodedClientCredentials];
        [MDMUtils savePreferance:ACCESS_TOKEN value:accessToken];
        [MDMUtils savePreferance:REFRESH_TOKEN value:refreshToken];
        NSString *enrollURL = [URLUtils getEnrollmentURLFromPlist];
        [MDMUtils saveDeviceUDID:UDID];
        NSString *serverURL = [URLUtils getServerURLFromPlist];
        if(enrollURL && ![@"" isEqualToString:enrollURL] && serverURL && ![@"" isEqualToString:serverURL]) {
            NSLog(@"Agent contains embedded values.");
            [URLUtils saveServerURL:serverURL];
            [URLUtils saveEnrollmentURL:enrollURL];
        }else {
            NSLog(@"Agent is using remote configs.");
            NSString *remoteServerURLHTTPS = [NSString stringWithFormat:@"https://%@", remoteServerURL];
            NSString *remoteEnrollmentURLHTTPS = [NSString stringWithFormat:@"https://%@", remoteEnrollmentURL];
            [URLUtils saveServerURL:remoteServerURLHTTPS];
            [URLUtils saveEnrollmentURL:remoteEnrollmentURLHTTPS];
        }
        NSLog(@"DEP config initiated.");
        [self registerForPushToken];
        [MDMUtils setEnrollStatus:ENROLLED];
        [self showLoginViewController];
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
    
    self.fetchCompletionHandler = completionHandler;
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
                [MDMUtils setLocationOperationId:operationId];
                NSLog(@"Location commmand, Time Remaining: %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
                [self initLocation];
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
    NSLog(@"didChangeAuthorizationStatus");
    if ([CLLocationManager locationServicesEnabled]) {
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self authorizeLocationService];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag && LOCATION_OFF_CODE == alertView.tag) {
        NSLog(@"Opening location settings");
        NSString* url = SYSTEM_VERSION_LESS_THAN(@"10.0") ?
            @"prefs:root=LOCATION_SERVICES" : @"App-Prefs:root=Privacy&path=LOCATION";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
    } else {
        if(buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}
-(CLLocationManager *)locationManager {
    if(_locationManager) {
        return _locationManager;
    }
    
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    _locationManager = manager;
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    _locationManager.allowsBackgroundLocationUpdates = YES;
    _locationManager.distanceFilter = kCLDistanceFilterNone;// Any movement change
    if (@available(iOS 11.0, *)) {
        _locationManager.showsBackgroundLocationIndicator = NO; //Hiding the location Update screen from user
    }
    return _locationManager;
}


- (void)initLocation {
    NSLog(@"Initializing location manager");
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Calling didFailWithError %@", [error localizedDescription]);
    if (self.fetchCompletionHandler) {
        self.fetchCompletionHandler(UIBackgroundFetchResultFailed);
        self.fetchCompletionHandler = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    NSLog(@"Sending location updates to the server");
    NSString *udid = [MDMUtils getDeviceUDID];
    CLLocation *location = [locations lastObject];
    
    if (location && udid) {
        [_connectionUtils sendLocationToServer:udid latitiude:location.coordinate.latitude longitude:location.coordinate.longitude];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.fetchCompletionHandler) {
            self.fetchCompletionHandler(UIBackgroundFetchResultNewData);
            self.fetchCompletionHandler = nil;
        }
    });
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
