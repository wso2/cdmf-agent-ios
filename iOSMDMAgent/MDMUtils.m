//
//  MDMUtils.m
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 2/19/15.
//  Copyright (c) 2015 WSO2. All rights reserved.
//

#import "MDMUtils.h"

@implementation MDMUtils

int LOCATION_DISTANCE_FILTER = 100;
NSString *const UDID = @"DEVICE_UDID";
NSString *const APS = @"aps";
NSString *const EXTRA = @"extra";
NSString *const OPERATION = @"operation";
NSString *const OPERATION_ID = @"operationId";
NSString *const SOUND_FILE_NAME = @"sound";
NSString *const SOUND_FILE_EXTENSION = @"caf";
NSString *const ENCLOSING_TAGS = @"<>";
NSString *const TOKEN_KEYCHAIN = @"TOKEN_KEYCHAIN1";
NSString *const CLIENT_DETAILS_KEYCHAIN = @"CLIENT_DETAILS_KEYCHAIN";
NSString *const ENROLL_STATUS = @"ENROLL_STATUS";
NSString *const ENROLLED = @"enrolled";
NSString *const UNENROLLED = @"unenrolled";
NSString *const LOCATION_OPERATION_ID = @"LOCATION_OPERATION_ID";

+ (void)saveDeviceUDID:(NSString *)udid {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:udid forKey:UDID];
    [userDefaults synchronize];
}

+ (NSString *)getDeviceUDID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:UDID];
}

+ (NSString *) getEnrollStatus {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:ENROLL_STATUS];
}

+ (void) setEnrollStatus: (NSString *)value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:ENROLL_STATUS];
    [userDefaults synchronize];
}


+ (NSString *) getLocationOperationId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:LOCATION_OPERATION_ID];
}

+ (void) setLocationOperationId: (NSString *)value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:LOCATION_OPERATION_ID];
    [userDefaults synchronize];
}

@end
