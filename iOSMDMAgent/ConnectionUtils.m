//
//  ConnectionUtils.m
//  iOSMDMAgent
//
//  Created by Dilshan Edirisuriya on 3/23/15.
//  Copyright (c) 2015 WSO2. All rights reserved.
//

#import "ConnectionUtils.h"
#import "URLUtils.h"
#import "MDMUtils.h"
#import "KeychainItemWrapper.h"

//Remove this code chunk in production
@interface NSURLRequest(Private)

+(void)setAllowsAnyHTTPSCertificate:(BOOL)inAllow forHost:(NSString *)inHost;

@end

@implementation ConnectionUtils

- (void)sendPushTokenToServer:(NSString *)udid pushToken:(NSString *)token {
    
    NSString *endpoint = [NSString stringWithFormat:[URLUtils getTokenPublishURL], udid];

    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTP_REQUEST_TIME];
    
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    [paramDictionary setValue:token forKey:TOKEN];

    [request setHTTPMethod:PUT];
    [request setHTTPBody:[[self dictionaryToJSON:paramDictionary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setContentType:request];
    [self addAccessToken:request];
    
    [self setAllowsAnyHTTPSCertificate:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int code = [(NSHTTPURLResponse *)response statusCode];
        
        if (code != HTTP_OK) {
            NSLog(@"Error occurred %i", code);
        }
    }];
}

- (void)sendLocationToServer:(NSString *)udid latitiude:(float)lat longitude:(float)longi {
    
    NSString *endpoint = [NSString stringWithFormat:[URLUtils getLocationPublishURL], udid];

    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTP_REQUEST_TIME];
    
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    [paramDictionary setObject:[NSNumber numberWithFloat:lat] forKey:LATITIUDE];
    [paramDictionary setObject:[NSNumber numberWithFloat:longi] forKey:LONGITUDE];
    [paramDictionary setObject:[MDMUtils getLocationOperationId] forKey:OPERATION_ID];

    [request setHTTPMethod:PUT];
    [request setHTTPBody:[[self dictionaryToJSON:paramDictionary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setContentType:request];
    
    [self addAccessToken:request];
    [self setAllowsAnyHTTPSCertificate:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int code = [(NSHTTPURLResponse *)response statusCode];
 
        if (code == OAUTH_FAIL_CODE) {
            if([self getNewAccessToken]){
                [self sendLocationToServer:udid latitiude:lat longitude:longi];
            }
            NSLog(@"Error occurred %i", code);
        }
    }];
}


- (void)sendOperationUpdateToServer:(NSString *)deviceId operationId:(NSString *)opId status:(NSString *)state {
    
    NSString *endpoint = [NSString stringWithFormat:[URLUtils getOperationURL], deviceId];

    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTP_REQUEST_TIME];
    
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    [paramDictionary setValue:opId forKey:OPERATION_ID];
    [paramDictionary setValue:state forKey:STATUS];

    [request setHTTPMethod:PUT];
    [request setHTTPBody:[[self dictionaryToJSON:paramDictionary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setContentType:request];
    
    [self addAccessToken:request];
    [self setAllowsAnyHTTPSCertificate:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int code = [(NSHTTPURLResponse *)response statusCode];
        
        if (code == OAUTH_FAIL_CODE) {
            if([self getNewAccessToken]){
                [self sendOperationUpdateToServer:deviceId operationId:opId status:state];
            }
            NSLog(@"Error occurred %i", code);
        }
     
    }];
}

- (void)sendUnenrollToServer {
    [self getNewAccessToken];
    NSURL *url = [NSURL URLWithString:[URLUtils getUnenrollURL]];

    NSString *deviceId = [MDMUtils getDeviceUDID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTP_REQUEST_TIME];
    NSArray *deviceList = @[deviceId];
    
    [request setHTTPMethod:POST];
    [self addAccessToken:request];
    [request setHTTPBody:[[self arrayToJSON:deviceList] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setContentType:request];
    
    [self setAllowsAnyHTTPSCertificate:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        int code = [(NSHTTPURLResponse *)response statusCode];

        if (code == OAUTH_FAIL_CODE) {
            if([self getNewAccessToken]){
                [self sendUnenrollToServer];
            }
            [MDMUtils setEnrollStatus:UNENROLLED];
    
        } else if (code == HTTP_CREATED) {
            
            if([_delegate respondsToSelector:@selector(unregisterSuccessful)]){
                [_delegate unregisterSuccessful];
            }
            
        } else {
            
            if([_delegate respondsToSelector:@selector(unregisterFailure:)]){
                [_delegate unregisterFailure:error];
            }
            
        }
    }];
}

- (void)addAccessToken:(NSMutableURLRequest *)request {
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:TOKEN_KEYCHAIN accessGroup:nil];
    NSString *storedAccessToken = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    if(storedAccessToken != nil){
        NSString *headerValue = [AUTHORIZATION_BEARER stringByAppendingString:storedAccessToken];
        [request setValue:headerValue forHTTPHeaderField:AUTHORIZATION];
    }
}


- (BOOL)getNewAccessToken {
    NSString *endpoint = [URLUtils getRefreshTokenURL];

    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTP_REQUEST_TIME];
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    
    
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:TOKEN_KEYCHAIN accessGroup:nil];
    NSString *storedRefreshToken = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    if(storedRefreshToken != nil){
        [paramDictionary setObject:storedRefreshToken forKey:REFRESH_TOKEN];
    }
    
    [paramDictionary setObject:GRANT_TYPE_VALUE forKey:GRANT_TYPE];
    [paramDictionary setObject:@"PRODUCTION" forKey:@"scope"];

    NSString *payload=[@"grant_type=refresh_token&refresh_token=" stringByAppendingString:storedRefreshToken];
    [request setHTTPMethod:POST];
    [request setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    [self setContentTypeFormEncoded:request];
    [self addClientDeatils:request];
    [self setAllowsAnyHTTPSCertificate:url];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        int code = [(NSHTTPURLResponse *)response statusCode];
        if (code == HTTP_OK) {
            NSError *jsonError;
            NSString *returnedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSData *objectData = [returnedData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            NSString *accessToken =(NSString*)[json objectForKey:@"access_token"];
            NSString *refreshToken =(NSString*)[json objectForKey:@"refresh_token"];
            KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:TOKEN_KEYCHAIN accessGroup:nil];
            [wrapper setObject:accessToken forKey:(__bridge id)(kSecAttrAccount)];
            [wrapper setObject:refreshToken forKey:(__bridge id)(kSecValueData)];
            
            return true;
        }
    }
    NSLog(@"Error while getting refresh token.");
    return false;
}

- (void)addClientDeatils:(NSMutableURLRequest *)request {
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:TOKEN_KEYCHAIN accessGroup:nil];
    NSString *storedClientDetails = [wrapper objectForKey:(__bridge id)(kSecAttrService)];
    if(storedClientDetails != nil){
        NSString *headerValue = [AUTHORIZATION_BASIC stringByAppendingString:storedClientDetails];
        [request setValue:headerValue forHTTPHeaderField:AUTHORIZATION];
    }
}

- (void)setContentType:(NSMutableURLRequest *)request {
    [request setValue:APPLICATION_JSON forHTTPHeaderField:CONTENT_TYPE];
    [request setValue:APPLICATION_JSON forHTTPHeaderField:ACCEPT];
}

- (void)setContentTypeFormEncoded:(NSMutableURLRequest *)request {
    [request setValue:FORM_ENCODED forHTTPHeaderField:CONTENT_TYPE];
}


- (void)setAllowsAnyHTTPSCertificate:(NSURL *)url {
    //remove this code chunk in production
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
}

-(NSString *)dictionaryToJSON:(NSDictionary *)dictionary {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}

-(NSString *)arrayToJSON:(NSArray *)array {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}

@end
