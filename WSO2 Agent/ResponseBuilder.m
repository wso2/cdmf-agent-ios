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
 * 	Description : - ResponseBuilder class for building the ResponseObject
 */

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

@end
