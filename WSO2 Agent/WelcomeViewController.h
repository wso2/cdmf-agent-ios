//
//  WelcomeViewController.h
//  WSO2 Agent
//
//  Created by WSO2 on 10/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnregisterViewController.h"
#import "ActivityView.h"
#import <QuartzCore/QuartzCore.h>
#import "Settings.h"
#import "RegisterDelegate.h"
#import "ResponseDelegate.h"
#import "ApiResponse.h"

#define RESOURCE_PLIST222 @"Niranjan"

@interface WelcomeViewController : UIViewController

@property (strong, nonatomic) ActivityView *activityView;

@property (weak, nonatomic) IBOutlet UITextField *server_txt;
@property (weak, nonatomic) IBOutlet UITextView *license_txtview;
@property (strong, nonatomic) IBOutlet UIView *license_view;
@property (weak, nonatomic) NSString *devUniqueID;

- (IBAction)server_btnact:(id)sender;
- (IBAction)agree_btnact:(id)sender;
- (IBAction)cancel_btnact:(id)sender;
@end
