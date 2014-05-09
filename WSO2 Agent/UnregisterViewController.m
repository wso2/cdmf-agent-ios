/**
 *  Copyright (c) 2011, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 * 	Description : - UnregisterViewController
 */

#import "UnregisterViewController.h"

@interface UnregisterViewController () <UnregisterDelegate, RegisterDelegate> {

    ApiResponse *_manager;
}
@end

@implementation UnregisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_logo.png"]];
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,125,32)];
        [titleView addSubview:imageView];
        self.navigationItem.titleView = titleView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unregisterSuccess) name:UNREGISTERSUCCESS object:nil];
    
    // Do any additional setup after loading the view from its nib.
    _manager = [[ApiResponse alloc] init];
    _manager.unregisterDelegate = self;
    _manager.registerDelegate = self;
    
    self.activityView = [[ActivityView alloc] init];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientatio {
    [self rotateLicenseView];
}

- (void) rotateLicenseView {
    
    CGFloat xSize = self.view.frame.size.width;
    CGFloat ySize = self.view.frame.size.height;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {        
        self.activityView.frame = CGRectMake(0, 0, ySize, xSize);
        self.activityView.msgLabel.frame = CGRectMake(0, self.view.center.y - 20.0, xSize, 22);
        self.activityView.activityIndicator.frame = CGRectMake(0, self.view.center.y + 10, ySize, 37);
    } else {        
        self.activityView.frame = CGRectMake(0, 0, xSize, ySize);
        self.activityView.msgLabel.frame = CGRectMake(0, self.view.center.y - 20.0, self.view.frame.size.width, 22);
        self.activityView.activityIndicator.frame = CGRectMake(0, self.view.center.y + 10, self.view.frame.size.width, 37);
    }
}

- (IBAction)unregister_btnact:(id)sender {
    
    self.activityView.msgLabel.text = @"Please wait while device unregisters...";
    self.activityView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.activityView.msgLabel.frame = CGRectMake(0, self.view.center.y - 20.0, self.view.frame.size.width, 22);
    self.activityView.activityIndicator.frame = CGRectMake(0, self.view.center.y + 10, self.view.frame.size.width, 37);
    [self.view addSubview:self.activityView];
    
    NSString *uniqueDevice = [Settings getDeviceUnique];
    [_manager unregisterFromMDM:uniqueDevice withCallback:NULL];
    self.unregisterFailed = FALSE;
    self.isPopToRoot = FALSE;

}


- (void) popToWelcomeScreen {
    
    if (![self isPopToRoot]) {
        
        self.isPopToRoot = TRUE;
        [self.activityView removeFromSuperview];
    
        NSMutableArray *viewContArray = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        
        WelcomeViewController *welcomeViewController;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
        } else {
            welcomeViewController = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController_iPad" bundle:nil];
        }
        
        [viewContArray replaceObjectAtIndex:0 withObject:welcomeViewController];
        [self.navigationController setViewControllers:viewContArray];
    
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) unregisterSuccess {
    if (![self unregisterFailed]) {
        if (![Settings isDeviceRegistered]) {
            //Device is unregistered
            [self performSelectorOnMainThread:@selector(popToWelcomeScreen) withObject:nil waitUntilDone:NO];
        } else {
            [_manager isRegistered:[Settings getDeviceUnique] withCallback:NULL];
        }
    } else {
        //Unregister failed
        [self performSelectorOnMainThread:@selector(displayErrorMsgOnMain) withObject:nil waitUntilDone:NO];
    }
}

- (void) displayErrorMsgOnMain : (ResponseObject *) responseObject {
    self.unregisterFailed = TRUE;
    [[[UIAlertView alloc] initWithTitle:responseObject.errorTitle message:responseObject.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}


#pragma Delegate Calls

- (void) didReceiveRegistration:(ResponseObject *) responseObject {
    
    if (responseObject.isSuccess == TRUE) {
        if (responseObject.registered == TRUE) {
            //Device not unregistered
        } else {
            //Device has been unregistered successfully
            [Settings updatePlist:DEVICEREG StringText:@"FALSE"];
            [self performSelectorOnMainThread:@selector(popToWelcomeScreen) withObject:nil waitUntilDone:NO];
        }
    } else {
        [self registerFailedWithError:responseObject];
    }
}

- (void) registerFailedWithError:(ResponseObject *) responseObject {
    [self performSelectorOnMainThread:@selector(displayErrorMsgOnMain) withObject:responseObject.message waitUntilDone:NO];
}

- (void) unregisterFailedWithError:(ResponseObject *) responseObject {
    [self performSelectorOnMainThread:@selector(displayErrorMsgOnMain) withObject:responseObject.message waitUntilDone:NO];
}

- (void) onSuccessUnregister:(ResponseObject *) responseObject {
    [Settings updatePlist:DEVICEREG StringText:@"FALSE"];
    [self performSelectorOnMainThread:@selector(popToWelcomeScreen) withObject:nil waitUntilDone:NO];
}

@end
