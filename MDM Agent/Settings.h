//
//  Settings.h
//  WSO2 Agent
//
//  Created by WSO2 on 10/8/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>

#define URL_PREFIX @"https://"
#define PORT @":9443"
#define HTTP_REQUEST_TIME @"10.0"
#define SUCCESS_STATUS @"200"
#define RESOURCE_PLIST @"Resource"
#define ENDPOINT_PLIST @"Endpoints"
#define SERVER_URL @"Server_url"
#define DEVICEREG @"DeviceReg"
#define ISLICENSEAGREED @"isLicenseAgreed"
#define INFORMATION @"Information"
#define PUSH_TOKEN @"Push_Token"
#define TOKENPUSHEDSERVER @"Token_Pushed_Server";

#define UNREGISTER @"unregister"
#define ISREGISTERED @"isregistered"
#define GETLICENSE @"getlicense"
#define PUSHTOKENTOSERVER @"pushtokentoserver"
#define LOCATIONURL @"locationurl"
#define LOGINURL @"loginurl"

#define FAILED @"FAILED"
#define UNREGISTRATION @"UNREGISTRATION"
#define ISDEVICEREGISTERED @"ISDEVICEREGISTERED"
#define LICENSE @"LICENSE"
#define SERVERPUSHTOKEN @"SERVERPUSHTOKEN"
#define UNREGISTERSUCCESS @"UNREGISTERSUCCESS"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define DEVICE_UDID @"UDID"


@interface Settings : NSObject

+ (NSString *) getDeviceUnique;
+ (NSString *) getMacAddress;
+ (NSString *) getServerURL: (NSString *) resourcename;
+ (NSString *) getEndpoint: (NSString *) resourcename;
+ (BOOL) isDeviceRegistered;
+ (void) copyResource;
//+ (void) saveRegistered: (NSString *) regValue;
+ (void) licenseAgreed;
+ (BOOL) isLicenseAgreed;
+ (BOOL) isPushedToServer;
//+ (void) saveUDID: (NSString *) udid;
+ (NSString *) getResourcePlist: (NSString *) objectKey;
+ (void) updatePlist: (NSString *) listKey StringText: (NSString *) stringValue;

@end
