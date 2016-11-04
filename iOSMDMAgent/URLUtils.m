//
//  URLUtils.m
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 3/23/15.
//  Copyright (c) 2015 WSO2. All rights reserved.
//

#import "URLUtils.h"

@implementation URLUtils

float const HTTP_REQUEST_TIME = 60.0f;
int HTTP_OK = 200;
int HTTP_CREATED = 201;
int OAUTH_FAIL_CODE = 401;
NSString *const ENDPOINT_FILE_NAME = @"Endpoints";
NSString *const EXTENSION = @"plist";
NSString *const TOKEN_PUBLISH_URI = @"TOKEN_PUBLISH_URI";
NSString *const ENROLLMENT_URI = @"ENROLLMENT_URI";
NSString *const OPERATION_URI = @"OPERATION_URI";
NSString *const LOCATION_PUBLISH_URI = @"LOCATION_PUBLISH_URI";
NSString *const SERVER_URL = @"SERVER_URL";
NSString *const CONTEXT_URI = @"SERVER_CONTEXT";
NSString *const TOKEN = @"token";
NSString *const GET = @"GET";
NSString *const POST = @"POST";
NSString *const PUT = @"PUT";
NSString *const ACCEPT = @"Accept";
NSString *const CONTENT_TYPE = @"Content-Type";
NSString *const APPLICATION_JSON = @"application/json";
NSString *const LATITIUDE = @"latitude";
NSString *const LONGITUDE = @"longitude";
NSString *const UNENROLLMENT_PATH = @"UNENROLLMENT_PATH";
NSString *const AUTHORIZATION_BASIC = @" Basic ";
NSString *const AUTHORIZATION_BEARER = @" Bearer ";
NSString *const AUTHORIZATION = @"Authorization";
NSString *const REFRESH_TOKEN_URI =@"REFRESH_TOKEN_URI";
NSString *const REFRESH_TOKEN = @"refresh_token";
NSString *const GRANT_TYPE = @"grant_type";
NSString *const GRANT_TYPE_VALUE = @"refresh_token";
NSString *const FORM_ENCODED = @"application/x-www-form-urlencoded";
NSString *const OPERATION_ID_RESPOSNE = @"operationId";
NSString *const STATUS = @"status";


+ (NSDictionary *)readEndpoints {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:ENDPOINT_FILE_NAME ofType:EXTENSION];
    return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

+ (NSString *)getServerURL {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:SERVER_URL];
}

+ (NSString *)getEnrollmentURL {
    return [NSString stringWithFormat:@"%@%@", [URLUtils getServerURL], [[URLUtils readEndpoints] objectForKey:ENROLLMENT_URI]];
}

+ (NSString *)getContextURL {
    return [[URLUtils readEndpoints] objectForKey:CONTEXT_URI];
}

+ (void)saveServerURL:(NSString *)serverURL {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:serverURL forKey:SERVER_URL];
    [userDefaults synchronize];
}

+ (NSString *)getTokenPublishURL {
    return [NSString stringWithFormat:@"%@%@%@", [URLUtils getServerURL], [URLUtils getContextURL], [[URLUtils readEndpoints] objectForKey:TOKEN_PUBLISH_URI]];
}

+ (NSString *)getLocationPublishURL {
    return [NSString stringWithFormat:@"%@%@%@", [URLUtils getServerURL], [URLUtils getContextURL], [[URLUtils readEndpoints] objectForKey:LOCATION_PUBLISH_URI]];
}

+ (NSString *)getOperationURL {
    return [NSString stringWithFormat:@"%@%@%@", [URLUtils getServerURL], [URLUtils getContextURL], [[URLUtils readEndpoints] objectForKey:OPERATION_URI]];
}

+ (NSString *)getUnenrollURL {
    return [NSString stringWithFormat:@"%@%@%@", [URLUtils getServerURL], [URLUtils getContextURL], [[URLUtils readEndpoints] objectForKey:UNENROLLMENT_PATH]];
}

+ (NSString *)getRefreshTokenURL{
    return [NSString stringWithFormat:@"%@%@", [URLUtils getServerURL], [[URLUtils readEndpoints] objectForKey:REFRESH_TOKEN_URI]];
}

@end
