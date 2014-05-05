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

#import <UIKit/UIKit.h>
#import "ActivityView.h"
#import "WelcomeViewController.h"
#import "Settings.h"
#import "ApiResponse.h"
#import "UnregisterDelegate.h"
#import "RegisterDelegate.h"

@interface UnregisterViewController : UIViewController

@property (nonatomic, assign) BOOL unregisterFailed;
@property (nonatomic, assign) BOOL isPopToRoot;
@property (strong, nonatomic) ActivityView *activityView;

- (IBAction)unregister_btnact:(id)sender;

@end
