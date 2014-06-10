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
 * 	Description : - Unit test implementations for ApiResponse class
 */


#import <SenTestingKit/SenTestingKit.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import "Settings.h"
#import "TestConstants.h"
#import "ApiResponse.h"
#import "AsyncSenTestCase.h"


@interface ApiResponseTest : AsyncSenTestCase
{

}
@end

@interface ApiResponseTest () {
    ApiResponse *apiResponse;
}

@end

@implementation ApiResponseTest


- (void)setUp
{
    [super setUp];
    [OHHTTPStubs removeAllStubs];
    [Settings copyResource];
    apiResponse = [[ApiResponse alloc] init];
    [Settings updatePlist:DEVICE_UDID StringText:TEST_UDID];
    [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {
        NSLog(@"%@ stubbed by %@", request.URL, stub.name);
    }];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

- (void) testisRegistered
{
    //Request data
    NSString *postData = [NSString stringWithFormat:@"udid=%@", TEST_UDID];
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        //request url
        return [[request.URL path]isEqualToString:@"/mdm/api/devices/isregistered"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        //Response for request
        if([[request HTTPMethod] isEqualToString:@"POST"] && [[NSString stringWithUTF8String:[[request HTTPBody] bytes]] isEqualToString:postData]){
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:200 headers:nil] requestTime:0.0f responseTime:0.0f];
        }else{
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:400 headers:nil] requestTime:0.0f responseTime:0.0f];
        }
    }];
    stub.name = @"IsRegisteredStub";

   [apiResponse isRegistered:TEST_UDID withCallback:^(ResponseObject *responseObj, BOOL success) {
       if(success){
           STAssertTrue(responseObj.isSuccess, @"Invalid response from ResponseBuilder for isRegistered");
           [self notifyAsyncOperationDone];
       }else{
           STAssertFalse(responseObj.isSuccess, @"Invalid response from ResponseBuilder");
           STAssertEqualObjects(responseObj.message, @"Error connecting to Server!!!", @"Invalid response message in ResponseObject");
           STAssertEqualObjects(responseObj.errorTitle, @"Connection Error", @"Invalid error title in ResponseObject");
           [self notifyAsyncOperationDone];
       }
   }];

    [self waitForAsyncOperationWithTimeout:5.0f];
}

- (void) testgetLicense
{
    NSString *testLicense = @"WSO2 EMM License";
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[request.URL path]isEqualToString:@"/mdm/api/devices/license"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if([[request HTTPMethod] isEqualToString:@"GET"]){
            return [[OHHTTPStubsResponse responseWithData:[testLicense dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:nil] requestTime:0.0f responseTime:0.0f];
        }else{
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:400 headers:nil] requestTime:0.0f responseTime:0.0f];
        }
    }];
    stub.name = @"getLicenseStub";
    
    [apiResponse getLicense:^(ResponseObject *responseObj, BOOL success) {
        if(success){
            STAssertTrue(responseObj.isSuccess, @"Invalid response from ResponseBuilder for getLicense");
            STAssertEqualObjects(responseObj.message, testLicense, @"License mismatch in ResponseObject");
            [self notifyAsyncOperationDone];
        }else{
            STAssertFalse(responseObj.isSuccess, @"Invalid response from ResponseBuilder");
            STAssertEqualObjects(responseObj.message, @"Error connecting to Server!!!", @"Invalid response message in ResponseObject");
            STAssertEqualObjects(responseObj.errorTitle, @"Connection Error", @"Invalid error title in ResponseObject");
            [self notifyAsyncOperationDone];
        }
    }];
    
    [self waitForAsyncOperationWithTimeout:5.0f];

}

- (void) testunregisterFromMDM
{
    //Request data
    NSString *postData = [NSString stringWithFormat:@"udid=%@", TEST_UDID];
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        //request url
        return [[request.URL path]isEqualToString:@"/mdm/api/devices/unregisterios"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        //Response for request
        if([[request HTTPMethod] isEqualToString:@"POST"] && [[NSString stringWithUTF8String:[[request HTTPBody] bytes]] isEqualToString:postData]){
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:200 headers:nil] requestTime:0.0f responseTime:0.0f];
        }else{
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:400 headers:nil] requestTime:0.0f responseTime:0.0f];
        }
    }];
    stub.name = @"unregisterStub";
    
    [apiResponse unregisterFromMDM:TEST_UDID withCallback:^(ResponseObject *responseObj, BOOL success) {
        if(success){
            STAssertNotNil(responseObj, @"Invalid device registered status");
            [self notifyAsyncOperationDone];
        }else{
            STAssertFalse(responseObj.isSuccess, @"Invalid response from ResponseBuilder");
            STAssertEqualObjects(responseObj.message, @"Error connecting to Server!!!", @"Invalid response message in ResponseObject");
            STAssertEqualObjects(responseObj.errorTitle, @"Connection Error", @"Invalid error title in ResponseObject");
            [self notifyAsyncOperationDone];
        }
    }];
    
    [self waitForAsyncOperationWithTimeout:5.0f];
}

- (void) testsendPushTokenToServer
{
    //Request data
    NSString *postData = [NSString stringWithFormat:@"udid=%@&pushToken=%@", TEST_UDID, TEST_PUSH_TOKEN];
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        //request url
        return [[request.URL path]isEqualToString:@"/mdm/api/devices/pushtoken"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        //Response for request
        if([[request HTTPMethod] isEqualToString:@"POST"] && [[NSString stringWithUTF8String:[[request HTTPBody] bytes]] isEqualToString:postData]){
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:200 headers:nil] requestTime:0.0f responseTime:0.0f];
        }else{
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:400 headers:nil] requestTime:0.0f responseTime:0.0f];
        }
    }];
    stub.name = @"sendPushTokenStub";
    
    [apiResponse sendPushTokenToServer:TEST_PUSH_TOKEN UDID:TEST_UDID withCallback:^(ResponseObject *responseObj, BOOL success) {
        if(success){
            STAssertNotNil(responseObj, @"Invalid response from ResponseBuilder for sendPushToken");
            [self notifyAsyncOperationDone];
        }else{
            STAssertFalse(responseObj.isSuccess, @"Invalid response from ResponseBuilder");
            STAssertEqualObjects(responseObj.message, @"Error connecting to Server!!!", @"Invalid response message in ResponseObject");
            STAssertEqualObjects(responseObj.errorTitle, @"Connection Error", @"Invalid error title in ResponseObject");
            [self notifyAsyncOperationDone];
        }
    }];
    
    [self waitForAsyncOperationWithTimeout:5.0f];
    
}

- (void) testsendLocationToServer
{
    //Dummy location object
    CLLocation *location  = [[CLLocation alloc] initWithLatitude:TEST_LATITUDE longitude:TEST_LONGITITUDE];
    //Request data
    NSString *postData = [NSString stringWithFormat:@"udid=%@&latitude=%f&longitude=%f", TEST_UDID,TEST_LATITUDE,TEST_LONGITITUDE];
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        //request url
        return [[request.URL path]isEqualToString:@"/mdm/api/devices/location"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        //Response for request
        if([[request HTTPMethod] isEqualToString:@"POST"] && [[NSString stringWithUTF8String:[[request HTTPBody] bytes]] isEqualToString:postData]){
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:200 headers:nil] requestTime:0.0f responseTime:0.0f];
        }else{
            return [[OHHTTPStubsResponse responseWithData:NULL statusCode:400 headers:nil] requestTime:0.0f responseTime:0.0f];
        }
    }];
    stub.name = @"sendLocationStub";
    
    [apiResponse sendLocationToServer:location withCallback:^(ResponseObject *responseObj, BOOL success) {
        if(success){
            STAssertNil(responseObj, @"Invalid response from ResponseBuilder");
            [self notifyAsyncOperationDone];
        }else{
            STAssertFalse(responseObj.isSuccess, @"Invalid response from ResponseBuilder");
            STAssertEqualObjects(responseObj.message, @"Error connecting to Server!!!", @"Invalid response message in ResponseObject");
            STAssertEqualObjects(responseObj.errorTitle, @"Connection Error", @"Invalid error title in ResponseObject");
            [self notifyAsyncOperationDone];
        }
    }];
    
    [self waitForAsyncOperationWithTimeout:5.0f];

}
@end
