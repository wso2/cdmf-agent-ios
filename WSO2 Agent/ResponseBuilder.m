//
//  ResponseBuilder.m
//  WSO2 Agent
//
//  Created by WSO2 on 11/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import "ResponseBuilder.h"

@implementation ResponseBuilder


+ (ResponseObject *) httpResponse: (NSURLResponse *) urlResponse body: (NSData *) data error: (NSError **) error requestHeader: (NSString *) request {
    
    ResponseObject *responseObject = [[ResponseObject alloc] init];
    
    if ([request isEqualToString:LICENSE]) {
        responseObject.isSuccess = TRUE;
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (response == NULL) {
            //Connection success but License is not changed
            response = nil;
        }
        responseObject.message = [response copy];
    } else if ([request isEqualToString:FAILED]) {
        responseObject.isSuccess = FALSE;
        responseObject.errorTitle = @"Connection Error";
        responseObject.message = @"Error connecting to Server!!!";
    } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) urlResponse;
        int statusCode = [httpResponse statusCode];
        
        if ([request isEqualToString:ISDEVICEREGISTERED]) {
            responseObject.isSuccess = TRUE;
            if (statusCode == [SUCCESS_STATUS intValue])
                responseObject.registered = TRUE;
            else
                responseObject.registered = FALSE;
        } else if ([request isEqualToString:UNREGISTRATION]) {
            if (statusCode == [SUCCESS_STATUS intValue]) {
                responseObject.registered = FALSE;
                responseObject.message = @"Device will be unregistrated in a few minutes.";
            } else {
                responseObject.registered = TRUE;
                responseObject.message = @"Unregistration failed! Please try again!";
            }
        } else {
            if (statusCode == [SUCCESS_STATUS intValue]) {
                responseObject.isSuccess = TRUE;
            } else {
                responseObject.isSuccess = FALSE;
            }
        }
    }
    
    return responseObject;
}

/*
+ (ResponseObject *)getStringFromJSON: (NSData *) data requestHeader: (NSString *) request {
    ResponseObject *responseObject = [[ResponseObject alloc] init];
    NSString *response;
    
    if ([request isEqualToString:LICENSE]) {
        responseObject.isSuccess = TRUE;
        response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (response == NULL) {
            //Connection success but License is not changed
            response = nil;
        }
        responseObject.message = [response copy];
    } else if ([request isEqualToString:FAILED]) {
        responseObject.isSuccess = FALSE;
        responseObject.errorTitle = @"Connection Error";
        responseObject.message = @"Error connecting to Server!!!";
    } else {
        response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        if (response == NULL) {
            return nil;
            responseObject.isSuccess = FALSE;
        } else {
            response = [response stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            response = [response substringFromIndex:1];
            response = [response substringToIndex:[response length] -1];
            response = [response stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
            if ([request isEqualToString:ISDEVICEREGISTERED]) {
                responseObject.isSuccess = TRUE;
                if ([response isEqualToString:SUCCESS_STATUS])
                    responseObject.isRegistered = TRUE;
                else
                    responseObject.isRegistered = FALSE;
            } else if ([response isEqualToString:SUCCESS_STATUS]) {
                //Success
                responseObject.isSuccess = TRUE;
            } else {
                responseObject.isSuccess = FALSE;
                responseObject.errorTitle = @"Error";
                responseObject.message = @"Invalid data";
            }
        }
        
    }
    
    return responseObject;
}
 */


@end
