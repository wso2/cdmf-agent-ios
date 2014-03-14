//
//  WebViewController.h
//  WSO2 Agent
//
//  Created by WSO2 on 10/8/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "UnregisterViewController.h"
#import "ApiResponse.h"
#import "RegisterDelegate.h"

@interface WebViewController : UIViewController < NSURLConnectionDelegate, UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, assign) BOOL firstDisplay;

@end
