//
//  ApiResponse.m
//  WSO2 Agent
//
//  Created by WSO2 on 11/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import "ApiResponse.h"


@implementation ApiResponse

- (void) isRegistered: (NSString *) uniqueID {
    
    NSString *endpoint = [Settings getServerURL: ISREGISTERED];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [@"udid=" stringByAppendingString:uniqueID];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            //[self.registerDelegate registerFailedWithError:[ResponseBuilder getStringFromJSON:nil requestHeader:FAILED]];
            [self.registerDelegate registerFailedWithError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
        } else {
            //[self.registerDelegate didReceiveRegistration:[ResponseBuilder getStringFromJSON:data requestHeader:ISDEVICEREGISTERED]];
            [self.registerDelegate didReceiveRegistration:[ResponseBuilder httpResponse:response body:data error:&error requestHeader:ISDEVICEREGISTERED]];
        }
    }];
}

- (void) getLicense {

    NSString *endpoint = [Settings getServerURL:GETLICENSE];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.responseDelegate licenseWithError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
        } else {
            //[self.responseDelegate getLicense:[ResponseBuilder getStringFromJSON:data requestHeader:LICENSE]];
            [self.responseDelegate getLicense:[ResponseBuilder httpResponse:response body:data error:&error requestHeader:LICENSE]];
        }
    }];
}

- (void) unregisterFromMDM:(NSString *)uniqueID {
    
    NSString *endpoint = [Settings getServerURL: UNREGISTER];
    //endpoint = [endpoint stringByAppendingFormat:@"?deviceID=%@", uniqueID];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [@"udid=" stringByAppendingString:uniqueID];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.unregisterDelegate unregisterFailedWithError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
        } else {
            //[self.unregisterDelegate onSuccessUnregister:[ResponseBuilder getStringFromJSON:data requestHeader:UNREGISTRATION]];
            [self.unregisterDelegate onSuccessUnregister:[ResponseBuilder httpResponse:response body:data error:&error requestHeader:UNREGISTRATION]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UNREGISTERSUCCESS object:self];
        }
    }];
}

- (void) sendLocationToServer: (CLLocation *)location {
    NSString *endpoint = [Settings getServerURL:LOCATIONURL];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"udid=%@&latitude=%f&longitude=%f", [Settings getResourcePlist:DEVICE_UDID], location.coordinate.latitude, location.coordinate.longitude];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.pushDelegate connectionError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
        } 
    }];
}

- (void) sendPushTokenToServer: (NSString *) pushToken UDID: (NSString *) udid {
    NSString *endpoint = [Settings getServerURL:PUSHTOKENTOSERVER];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[HTTP_REQUEST_TIME floatValue]];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"udid=%@&pushToken=%@", [Settings getResourcePlist:DEVICE_UDID], pushToken];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.pushDelegate connectionError:[ResponseBuilder httpResponse:nil body:nil error:&error requestHeader:FAILED]];
        } else {
            [self.pushDelegate onSuccessPushToken:[ResponseBuilder httpResponse:response body:data error:&error requestHeader:SERVERPUSHTOKEN]];
        }
    }];
}

@end
