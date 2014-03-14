//
//  WelcomeViewController.m
//  WSO2 Agent
//
//  Created by WSO2 on 10/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController () <ResponseDelegate, RegisterDelegate> {
    ApiResponse *_manager;
}

@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_logo.png"]];
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,125,32)];
        [titleView addSubview:imageView];
        self.navigationItem.titleView = titleView;
        
        [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                                   initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil]];
    }
    return self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _manager = [[ApiResponse alloc] init];
    _manager.registerDelegate = self;
    _manager.responseDelegate = self;
    
    //NSString *UDID = [device uniqueIdentifier];
    
    self.activityView = [[ActivityView alloc] init];
    self.server_txt.text = [Settings getResourcePlist:SERVER_URL];
    //self.server_txt.text = [self getFromResource:@"Server_url"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkDeviceRegistered)
                                                name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setServer_txt:nil];
    [self setLicense_txtview:nil];
    [self setLicense_view:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    //Before iOS 6
    // Return YES for supported orientations
    [self rotateLicenseView];
    
    return YES;
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [self rotateLicenseView];
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientatio {
    [self rotateLicenseView];
}

- (BOOL) shouldAutorotate {
    //After iOS 6
    // Return YES for supported orientations
    [self rotateLicenseView];
    return YES;
}

- (void) rotateLicenseView {
    
    CGFloat xSizePop = [self.navigationController.view frame].size.width;
    CGFloat ySizePop = [self.navigationController.view frame].size.height;
    CGFloat xSize = self.view.frame.size.width;
    CGFloat ySize = self.view.frame.size.height;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        self.license_view.frame = CGRectMake(0, 0, ySizePop, xSizePop);
        self.license_txtview.frame = CGRectMake(0, 44, ySizePop, xSizePop - 187);
        
        self.activityView.frame = CGRectMake(0, 0, ySize, xSize);
        self.activityView.msgLabel.frame = CGRectMake(0, self.view.center.y - 20.0, xSize, 22);
        self.activityView.activityIndicator.frame = CGRectMake(0, self.view.center.y + 10, ySize, 37);
    } else {
        self.license_view.frame = CGRectMake(0, 0, xSizePop, ySizePop);
        self.license_txtview.frame = CGRectMake(0, 44, xSizePop, ySizePop - 187);
        
        self.activityView.frame = CGRectMake(0, 0, xSize, ySize);
        self.activityView.msgLabel.frame = CGRectMake(0, self.view.center.y - 20.0, self.view.frame.size.width, 22);
        self.activityView.activityIndicator.frame = CGRectMake(0, self.view.center.y + 10, self.view.frame.size.width, 37);
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)server_btnact:(id)sender {
    
//    self.activityView.msgLabel.text = @"Connecting to Server...";
//    self.activityView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    self.activityView.msgLabel.frame = CGRectMake(0, self.view.center.y - 20.0, self.view.frame.size.width, 22);
//    self.activityView.activityIndicator.frame = CGRectMake(0, self.view.center.y + 10, self.view.frame.size.width, 37);
    
//    [self activityViewSettings:@"Connecting to Server..."];
//    [self.view addSubview:self.activityView];
//    
//    [self.server_txt resignFirstResponder];
//    [self updatePlist: @"Server_url" StringText:self.server_txt.text];
//    [self isRegisteredDevice];
    
    [self updatePlist: @"Server_url" StringText:self.server_txt.text];
    NSString *endpoint = [Settings getServerURL:LOGINURL];
    NSURL *loginURL = [[NSURL alloc] initWithString:endpoint];
    [[UIApplication sharedApplication] openURL:loginURL];

}

- (IBAction)agree_btnact:(id)sender {
    [self.license_view removeFromSuperview];
    
    /*
    WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    webViewController.firstDisplay = TRUE;
    [self.navigationController pushViewController:webViewController animated:YES];
     */
    [Settings licenseAgreed];
    NSString *endpoint = [Settings getServerURL:LOGINURL];
    NSURL *loginURL = [[NSURL alloc] initWithString:endpoint];
    [[UIApplication sharedApplication] openURL:loginURL];
    
}

- (IBAction)cancel_btnact:(id)sender {
    [self.license_view removeFromSuperview];
}

- (void) activityViewSettings: (NSString *) message {
    self.activityView.msgLabel.text = message;
    self.activityView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.activityView.msgLabel.frame = CGRectMake(0, self.view.center.y - 20.0, self.view.frame.size.width, 22);
    self.activityView.activityIndicator.frame = CGRectMake(0, self.view.center.y + 10, self.view.frame.size.width, 37);
}

- (void) isRegisteredDevice {
    
    NSString *uniqueID = [Settings getDeviceUnique];
    self.devUniqueID = uniqueID;
    
    if (uniqueID == NULL) {
        //iOS 7 - Device is not registered
        //[_manager getLicense];
        [self removeLoadScreen];
    } else {
        //below iOS 7 - check registration
        [_manager isRegistered:uniqueID];
    }
}

- (void) popToUnregister {
    //The device is already registered.. Jump to Unregister screen
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[Settings saveRegistered: @"TRUE"];
    [Settings updatePlist:DEVICEREG StringText:@"TRUE"];
    
    NSMutableArray *viewContArray = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    
    
    UnregisterViewController *uregViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        uregViewController = [[UnregisterViewController alloc] initWithNibName:@"UnregisterViewController" bundle:nil];
    } else {
        uregViewController = [[UnregisterViewController alloc] initWithNibName:@"UnregisterViewController_iPad" bundle:nil];
    }
    [viewContArray replaceObjectAtIndex:0 withObject:uregViewController];
    [self.navigationController setViewControllers:viewContArray];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) updateLicenseTextView: (NSString *) licenseText {
    
    [self removeLoadScreen];
    self.license_txtview.text = licenseText;
    [self.activityView removeFromSuperview];
    
    //[self.view addSubview:self.license_view];
}

- (void) removeLoadScreen {
    [self.activityView removeFromSuperview];
}

- (void) displayErrorMsgOnMain : (ResponseObject *) responseObject {
    [self removeLoadScreen];
    [[[UIAlertView alloc] initWithTitle:responseObject.errorTitle message:responseObject.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}

- (void) checkDeviceRegistered {
    //if ([Settings isLicenseAgreed]) {
        [self activityViewSettings:@"Checking registration..."];
        [self.view addSubview:self.activityView];
        [self isRegisteredDevice];
    //}
}

#pragma Delegate Calls

- (void) didReceiveRegistration:(ResponseObject *) responseObject {
    
    if (responseObject.isSuccess == TRUE) {
        if (responseObject.registered == TRUE) {
            //The device is already registered..
            [self performSelectorOnMainThread:@selector(popToUnregister) withObject:nil waitUntilDone:NO];
        } else {
            //The device is not registered.. Display License Agreement
            //[_manager getLicense];
            [self performSelectorOnMainThread:@selector(removeLoadScreen) withObject:nil waitUntilDone:NO];
        }
    } else {
        [self registerFailedWithError:responseObject];
    }
}

- (void) registerFailedWithError:(ResponseObject *) responseObject {
    
    [self performSelectorOnMainThread:@selector(displayErrorMsgOnMain:) withObject:responseObject waitUntilDone:NO];
}

- (void) getLicense: (ResponseObject *) responseObject {
    
    NSString *licenseString;
    if (responseObject.message == NULL) {
        
        licenseString = [Settings getResourcePlist:INFORMATION];
    } else {
        [self updatePlist:INFORMATION StringText:responseObject.message];
        licenseString = responseObject.message;
    }
    [self performSelectorOnMainThread:@selector(updateLicenseTextView:) withObject:licenseString waitUntilDone:NO];
}

- (void) licenseWithError:(ResponseObject *) responseObject {
    
    [self performSelectorOnMainThread:@selector(displayErrorMsgOnMain:) withObject:responseObject waitUntilDone:NO];
}


#pragma FileSystems

- (void) updatePlist: (NSString *) listKey StringText: (NSString *) stringValue{
    
    NSString *filePath = @"Resource.plist";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =  [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:filePath];
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [plistDict setValue:stringValue forKey:listKey];
    [plistDict writeToFile:plistPath atomically:YES];
}

/*
- (NSString *) getFromResource : (NSString *) listKey {
    
    NSString *filePath = @"Resource.plist";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =  [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:filePath];
    NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    return (NSString *)[plistDict objectForKey:listKey];
}
*/

@end
