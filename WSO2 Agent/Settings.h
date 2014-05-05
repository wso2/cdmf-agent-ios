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
 * 	Description : - Class with Utility methods
 */

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
+ (void) licenseAgreed;
+ (BOOL) isLicenseAgreed;
+ (BOOL) isPushedToServer;
+ (NSString *) getResourcePlist: (NSString *) objectKey;
+ (void) updatePlist: (NSString *) listKey StringText: (NSString *) stringValue;

@end
