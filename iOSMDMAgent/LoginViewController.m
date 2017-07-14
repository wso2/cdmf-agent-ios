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
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[URLUtils getEnrollmentURL]]];
    
//    NSURL *serverURL = [NSURL URLWithString:_serverURL.text];
//    
//    if (!_serverURL || [@"" isEqualToString:_serverURL.text]) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:EMPTY_URL message:EMPTY_URL_MESSAGE delegate:nil cancelButtonTitle:OK_BUTTON_TEXT otherButtonTitles:nil, nil];
//        [alertView show];
//    } else if(!serverURL) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:INVALID_SERVER_URL message:INVALID_SERVER_URL_MESSAGE delegate:nil cancelButtonTitle:OK_BUTTON_TEXT otherButtonTitles:nil, nil];
//        [alertView show];
//    } else {
//        [URLUtils saveServerURL:_serverURL.text];
//        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[URLUtils getEnrollmentURL]]];
//    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
