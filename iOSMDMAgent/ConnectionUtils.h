//
//  ConnectionUtils.h
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 3/23/15.
//  Copyright (c) 2015 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKProtocol.h"

@interface ConnectionUtils : NSObject

@property(nonatomic, assign) id<SDKProtocol> delegate;

- (void)sendPushTokenToServer:(NSString *)udid pushToken:(NSString *)token;
- (void)sendLocationToServer:(NSString *)udid latitiude:(float)lat longitude:(float)longi;
- (void)sendUnenrollToServer;
- (void)sendOperationUpdateToServer:(NSString *)deviceId operationId:(NSString *)opId status:(NSString *)state;

@end
