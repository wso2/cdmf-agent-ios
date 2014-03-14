//
//  UnregisterViewController.h
//  WSO2 Agent
//
//  Created by WSO2 on 10/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

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
