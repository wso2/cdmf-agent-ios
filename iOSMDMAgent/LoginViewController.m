//
//  LoginViewController.m
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 2/5/15.
//  Copyright (c) 2015 WSO2. All rights reserved.
//

#import "LoginViewController.h"
#import "URLUtils.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtServer.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickOnRegister:(id)sender {
    [self enroll];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtServer) {
        [textField resignFirstResponder];
        NSLog(@"Pressed GO");
        [self enroll];
        return NO;
    }
    NSLog(@"YES");
    return YES;
}

- (void)enroll {
    NSURL *serverURL = [NSURL URLWithString:self.txtServer.text];
    
    if (!self.txtServer || [@"" isEqualToString:self.txtServer.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:EMPTY_URL message:EMPTY_URL_MESSAGE delegate:nil cancelButtonTitle:OK_BUTTON_TEXT otherButtonTitles:nil, nil];
        [alertView show];
    } else if(!serverURL) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:INVALID_SERVER_URL message:INVALID_SERVER_URL_MESSAGE delegate:nil cancelButtonTitle:OK_BUTTON_TEXT otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        /*
         If the user is allowed to type the server url, assuption is this is not a production environment,
         Therefore, both Enrollment URL(manager node URL where the enrollment app is stored) and the gateway url are
         taken as the same. Check didChangeAuthorizationStatus method in AppDeligate.m for production behaviour,
         Where the URLs are hard coded.
        */
        [URLUtils saveServerURL:self.txtServer.text];
        [URLUtils saveEnrollmentURL:self.txtServer.text];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[URLUtils getEnrollmentURL]]];
    }
}

@end
