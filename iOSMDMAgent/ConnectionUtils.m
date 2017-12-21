//
//  ConnectionUtils.m
//  iOSMDMAgent
//

#import "ConnectionUtils.h"
#import "URLUtils.h"
#import "MDMUtils.h"

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
        long code = [(NSHTTPURLResponse *)response statusCode];
        NSString *returnedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (returnedData != nil) {
            NSLog(@"sendPushTokenToServer:Data recieved: %@", returnedData);
        }

        NSLog(@"sendPushTokenToServer:Response recieved: %ld", code);
        if (code == OAUTH_FAIL_CODE || code == 0) {
            NSLog(@"Authentication failed. Obtaining a new access token");
            if([self getNewAccessToken]){
                [self sendPushTokenToServer:udid pushToken:token];
            }
            NSLog(@"Error occurred %ld", code);
        }

    }];
}

- (void)enforceEffectivePolicy:(NSString *)deviceId {
    
    NSString *endpoint = [NSString stringWithFormat:[URLUtils getEffectivePolicyURL], deviceId];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTP_REQUEST_TIME];
    
    [request setHTTPMethod:GET];
    [self setContentType:request];
    [self addAccessToken:request];
    
    [self setAllowsAnyHTTPSCertificate:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        long code = [(NSHTTPURLResponse *)response statusCode];
        NSString *returnedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (returnedData != nil) {
            NSLog(@"enforceEffectivePolicy:Data recieved: %@", returnedData);
        }
        
        NSLog(@"enforceEffectivePolicy:Response recieved: %ld", code);
        if (code == OAUTH_FAIL_CODE || code == 0) {
            NSLog(@"Authentication failed. Obtaining a new access token");
            if([self getNewAccessToken]){
                [self enforceEffectivePolicy:deviceId];
            }
            NSLog(@"Error occurred %ld", code);
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
        long code = [(NSHTTPURLResponse *)response statusCode];
        
        NSString *returnedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (returnedData != nil) {
            NSLog(@"sendLocationUpdateToServer:Data recieved: %@", returnedData);
            [MDMUtils setLocationUpdatedTime];
        }

        NSLog(@"sendLocationToServer:Response recieved: %ld", code);
        if (code == OAUTH_FAIL_CODE || code == 0) {
            NSLog(@"Authentication failed. Obtaining a new access token");
            if([self getNewAccessToken]){
                [self sendLocationToServer:udid latitiude:lat longitude:longi];
            }
            NSLog(@"Error occurred %ld", code);
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
        long code = [(NSHTTPURLResponse *)response statusCode];
        
        NSString *returnedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (returnedData != nil) {
            NSLog(@"sendOperationUpdateToServer:Data recieved: %@", returnedData);
        }
        NSLog(@"sendOperationUpdateToServer:Response recieved: %ld", code);
        if (code == OAUTH_FAIL_CODE || code == 0) {
            NSLog(@"Authentication failed. Obtaining a new access token");
            if([self getNewAccessToken]){
                [self sendOperationUpdateToServer:deviceId operationId:opId status:state];
            }
            NSLog(@"Error occurred %ld", code);
        }
    }];
}

- (void)sendUnenrollToServer {
    //[self getNewAccessToken];
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
        long code = [(NSHTTPURLResponse *)response statusCode];
        NSString *returnedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (returnedData != nil) {
            NSLog(@"sendUnenrollToServer:Data recieved: %@", returnedData);
        }
        NSLog(@"sendUnenrollToServer:Response recieved: %ld", code);
        if (code == OAUTH_FAIL_CODE) {
            NSLog(@"Authentication failed. Obtaining a new access token");
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
    NSString *storedAccessToken = [MDMUtils getPreferance:ACCESS_TOKEN];

    if(storedAccessToken != nil){
        NSString *headerValue = [AUTHORIZATION_BEARER stringByAppendingString:storedAccessToken];
        [request setValue:headerValue forHTTPHeaderField:AUTHORIZATION];
    }
}


- (BOOL)getNewAccessToken {
    
    NSLog(@"getNewAccessToken: Obtaining a new access token");
    
    NSString *endpoint = [URLUtils getRefreshTokenURL];

    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTP_REQUEST_TIME];
    NSMutableDictionary *paramDictionary = [[NSMutableDictionary alloc] init];
    
    
    NSString *storedRefreshToken = [MDMUtils getPreferance:REFRESH_TOKEN];

    if(storedRefreshToken != nil){
        [paramDictionary setObject:storedRefreshToken forKey:REFRESH_TOKEN_LABEL];
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
        long code = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"getNewAccessToken:Response recieved: %li", code);
        if (code == HTTP_OK) {
            NSError *jsonError;
            NSString *returnedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSData *objectData = [returnedData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            NSString *accessToken =(NSString*)[json objectForKey:@"access_token"];
            NSString *refreshToken =(NSString*)[json objectForKey:@"refresh_token"];

            [MDMUtils savePreferance:ACCESS_TOKEN value:accessToken];
            [MDMUtils savePreferance:REFRESH_TOKEN value:refreshToken];

            return true;
        }
    }
    NSLog(@"Error while getting refresh token.");
    return false;
}

- (void)addClientDeatils:(NSMutableURLRequest *)request {

    NSString *storedClientDetails = [MDMUtils getPreferance:CLIENT_CREDENTIALS];

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
