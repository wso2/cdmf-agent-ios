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
 * 	Description : - Class with network operations
 */
#import "ApiResponse.h"


@implementation ApiResponse

- (void) isRegistered: (NSString *) uniqueID withCallback:(NSURLCompletionBlock)callback{
    
    NSString *endpoint = [Settings getServerURL: ISREGISTERED];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [@"udid=" stringByAppendingString:uniqueID];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if(callback){
                callback([ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED],FALSE);
            }else{
                [self.registerDelegate registerFailedWithError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
            }
        } else {
            if(callback){
                 callback([ResponseBuilder httpResponse:response body:data error:&error requestHeader:ISDEVICEREGISTERED],TRUE);
            }else{
                [self.registerDelegate didReceiveRegistration:[ResponseBuilder httpResponse:response body:data error:&error requestHeader:ISDEVICEREGISTERED]];
            }
        }
    }];
}

- (void) getLicense:(NSURLCompletionBlock)callback{

    NSString *endpoint = [Settings getServerURL:GETLICENSE];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if(callback){
                callback([ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED],FALSE);
            }else{
                [self.responseDelegate licenseWithError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
            }
        } else {
            if(callback){
                callback([ResponseBuilder httpResponse:response body:data error:&error requestHeader:LICENSE],TRUE);
            }else{
                [self.responseDelegate getLicense:[ResponseBuilder httpResponse:response body:data error:&error requestHeader:LICENSE]];
            }
        }
    }];
}

- (void) unregisterFromMDM:(NSString *)uniqueID withCallback:(NSURLCompletionBlock)callback{
    
    NSString *endpoint = [Settings getServerURL: UNREGISTER];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [@"udid=" stringByAppendingString:uniqueID];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if(callback){
                callback([ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED],FALSE);
            }else{
                [self.unregisterDelegate unregisterFailedWithError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
            }
        } else {
            if(callback){
                callback([ResponseBuilder httpResponse:response body:data error:&error requestHeader:UNREGISTRATION],TRUE);
            }else{
                [self.unregisterDelegate onSuccessUnregister:[ResponseBuilder httpResponse:response body:data error:&error requestHeader:UNREGISTRATION]];
                 [[NSNotificationCenter defaultCenter] postNotificationName:UNREGISTERSUCCESS object:self];
            }
        }

    }];
}

- (void) sendLocationToServer: (CLLocation *)location withCallback:(NSURLCompletionBlock)callback{
    NSString *endpoint = [Settings getServerURL:LOCATIONURL];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"udid=%@&latitude=%f&longitude=%f", [Settings getResourcePlist:DEVICE_UDID], location.coordinate.latitude, location.coordinate.longitude];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if(callback){
                callback([ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED],FALSE);
            }else{
                [self.pushDelegate connectionError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
            }
        } else {
            if(callback){
                callback(NULL,TRUE);
            }
        }
    }];
}

- (void) sendPushTokenToServer: (NSString *) pushToken UDID: (NSString *) udid withCallback:(NSURLCompletionBlock)callback{
    NSString *endpoint = [Settings getServerURL:PUSHTOKENTOSERVER];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"udid=%@&pushToken=%@", [Settings getResourcePlist:DEVICE_UDID], pushToken];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if(callback){
                callback([ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED],FALSE);
            }else{
                [self.pushDelegate connectionError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
            }
        } else {
            if(callback){
                callback([ResponseBuilder httpResponse:response body:data error:&error requestHeader:SERVERPUSHTOKEN],TRUE);
            }else{
                [self.pushDelegate onSuccessPushToken:[ResponseBuilder httpResponse:response body:data error:&error requestHeader:SERVERPUSHTOKEN]];
            }
        }
    }];
}

@end
