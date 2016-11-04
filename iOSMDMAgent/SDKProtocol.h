//
//  SDKProtocol.h
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 12/16/15.
//  Copyright © 2015 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDKProtocol <NSObject>

@optional

- (void)unregisterSuccessful;
- (void)unregisterFailure:(NSError *)error;

@end