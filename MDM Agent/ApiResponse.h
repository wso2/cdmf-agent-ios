//
//  ApiResponse.h
//  WSO2 Agent
//
//  Created by WSO2 on 11/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Settings.h"
#import "ResponseObject.h"
#import "ResponseBuilder.h"
#import "ResponseObject.h"

#import "RegisterDelegate.h"
#import "ResponseDelegate.h"
#import "UnregisterDelegate.h"
#import "PushDelegate.h"

@interface ApiResponse : NSObject

//Delegates
@property (weak, nonatomic) id<RegisterDelegate> registerDelegate;
@property (weak, nonatomic) id<ResponseDelegate> responseDelegate;
@property (weak, nonatomic) id<UnregisterDelegate> unregisterDelegate;
@property (weak, nonatomic) id<PushDelegate> pushDelegate;


- (void) isRegistered: (NSString *) uniqueID;
- (void) getLicense;
- (void) unregisterFromMDM: (NSString *) uniqueID;
- (void) sendPushTokenToServer: (NSString *) pushToken UDID: (NSString *) udid;
- (void) sendLocationToServer: (CLLocation *)location;

@end
