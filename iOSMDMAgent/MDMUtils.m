//
//  MDMUtils.m
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 2/19/15.
//  Copyright (c) 2015 WSO2. All rights reserved.
//

#import "MDMUtils.h"

#define MINUTE_IN_SECONDS 60
#define HOUR_IN_SECONDS 3600
#define DAY_IN_SECONDS 86400
#define WEEK_IN_SECONDS 604800
#define MONTH_IN_SECONDS 18144000

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
NSString *const ACCESS_TOKEN = @"ACCESS_TOKEN";
NSString *const REFRESH_TOKEN = @"REFRESH_TOKEN";
NSString *const CLIENT_CREDENTIALS = @"CLIENT_CREDENTIALS";
NSString *const TENANT_DOMAIN = @"TENANT_DOMAIN";
NSString *const LOCATION_UPDATED_TIME = @"LOCATION_UPDATED_TIME";

+ (void)saveDeviceUDID:(NSString *)udid {
    NSLog(@"Saving device UUID: %@", udid);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:udid forKey:UDID];
    [userDefaults synchronize];
}

+ (void)savePreferance:(NSString *)key value:(NSString *)val {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:val forKey:key];
    [userDefaults synchronize];
}

+ (NSString *)getPreferance:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
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

+ (void)setAccessToken:(NSString *)accessToken {
    NSLog(@"Saving access token : %@", accessToken);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:accessToken forKey:ACCESS_TOKEN];
    [userDefaults synchronize];
}

+ (void)setRefreshToken:(NSString *)refreshToken {
    NSLog(@"Saving refresh token : %@", refreshToken);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:refreshToken forKey:REFRESH_TOKEN];
    [userDefaults synchronize];
}

+ (NSString *)getAccessToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:ACCESS_TOKEN];
}

+ (NSString *)getRefreshToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:REFRESH_TOKEN];
}

+ (void)setClientCredentials:(NSString *)clientCredentials {
    NSLog(@"Saving client credentials : %@", clientCredentials);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:clientCredentials forKey:CLIENT_CREDENTIALS];
    [userDefaults synchronize];
}

+ (NSString *)getClientCredentials {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:CLIENT_CREDENTIALS];
}

+ (void)setTenantDomain:(NSString *)tenantDomain {
    NSLog(@"Saving tenant domain : %@", tenantDomain);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:tenantDomain forKey:TENANT_DOMAIN];
    [userDefaults synchronize];
}

+ (NSString *)getTenantDomain {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:TENANT_DOMAIN];
}

+ (void)setLocationUpdatedTime {
    NSDate* now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:now];
    NSLog(@"Saving location updated time : %@", currentTime);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:now forKey:LOCATION_UPDATED_TIME];
    [userDefaults synchronize];
}

+ (NSString *)getLocationUpdatedTime {
    NSLog(@"Getting location updated time");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate* date1 = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:date1];
    NSLog(@"Current time : %@", currentTime);
    
    NSDate* date2 = [userDefaults objectForKey:LOCATION_UPDATED_TIME];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    currentTime = [dateFormatter stringFromDate:date2];
    NSLog(@"Last updated time : %@", currentTime);
    
    if (date2 == nil) {
        NSLog(@"Location updated time is not available");
        return @"never";
    }
    
    NSTimeInterval distanceBetweenDates = [date1 timeIntervalSinceDate:date2];
    NSInteger syncTime = distanceBetweenDates/MONTH_IN_SECONDS;
    if (syncTime > 0) {
        NSLog(@"Getting location updated time from month format");
        return [NSString stringWithFormat:@"%li month(s) ago", (long)syncTime];
    }
    syncTime = distanceBetweenDates/WEEK_IN_SECONDS;
    if (syncTime > 0) {
        NSLog(@"Getting location updated time from week format");
        return [NSString stringWithFormat:@"%li week(s) ago", (long)syncTime];
    }
    syncTime = distanceBetweenDates/DAY_IN_SECONDS;
    if (syncTime > 0) {
        NSLog(@"Getting location updated time from day format");
        return [NSString stringWithFormat:@"%li day(s) ago", (long)syncTime];
    }
    syncTime = distanceBetweenDates/MINUTE_IN_SECONDS;
    if (syncTime > 0) {
        NSLog(@"Getting location updated time from minute format");
        return [NSString stringWithFormat:@"%li minute(s) ago", (long)syncTime];
    }

    NSLog(@"Getting location updated time from seconds format");
    return [NSString stringWithFormat:@"%li second(s) ago", (long)distanceBetweenDates];
}

@end
