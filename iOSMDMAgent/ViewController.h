//
//  ViewController.h
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 2/5/15.
//  Copyright (c) 2015 WSO2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDKProtocol.h"
#import "MDMConstants.h"

@interface ViewController : UIViewController <SDKProtocol, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnUnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnRefresh;


@property (strong, nonatomic) IBOutlet UILabel *lbLocationSync;


- (IBAction)clickOnUnRegister:(id)sender;
- (IBAction)refresh:(id)sender;

@end

