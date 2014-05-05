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
 * 	Description : - WelcomeViewController
 */

#import <UIKit/UIKit.h>
#import "UnregisterViewController.h"
#import "ActivityView.h"
#import <QuartzCore/QuartzCore.h>
#import "Settings.h"
#import "RegisterDelegate.h"
#import "ResponseDelegate.h"
#import "ApiResponse.h"

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
