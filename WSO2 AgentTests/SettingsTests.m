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
 * 	Description : - Unit test implementations for Settings class
 */

#import <SenTestingKit/SenTestingKit.h>
#import "Settings.h"
#import "TestConstants.h"


@interface SettingsTests : SenTestCase

@end

@implementation SettingsTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [Settings updatePlist:ISLICENSEAGREED StringText:@"FALSE"];
    [super tearDown];
}

- (void)testcopyResource
{
    id returnValue = [Settings getResourcePlist:SERVER_URL];
    STAssertEqualObjects(@"www.wso2.com",returnValue, @"Should have returned www.wso2.com");
}

- (void)testupdatePlist{
    [Settings updatePlist:TEST_KEY StringText:TEST_VALUE];
    STAssertEqualObjects(TEST_VALUE, [Settings getResourcePlist:TEST_KEY], @"getResourcePlist:TEST_KEY must return TEST VALUE after updatePlist invoke");
}

- (void)testgetMacAddress{
    NSString* returnValue = [Settings getMacAddress];
    BOOL isLengthEquals = ([returnValue length]==17)?TRUE:FALSE;
    STAssertTrue(isLengthEquals, @"Mac address must be a string of length 17");
}

- (void)testgetDeviceUnique{
    STAssertEqualObjects(TEST_UDID,[Settings getDeviceUnique], @"DeviceUnique parameter must return E1234 on initialization");
}

- (void)testgetServerURL{
    NSString *url =[NSString stringWithFormat:@"%@%@%@%@",URL_PREFIX, @"www.wso2.com", PORT,TEST_LOGIN_SERVER_ENDPOINT];
    STAssertEqualObjects(url,[Settings getServerURL:LOGINURL], @"GetServerURL:LOGINURL must return a valid url");
}

- (void)testgetEndPoint{
    STAssertNil([Settings getEndpoint:@""], @"GetEndPoint:nil must return nil.");
    STAssertEqualObjects(TEST_LOGIN_SERVER_ENDPOINT, [Settings getEndpoint:LOGINURL], @"GetEndPoint:LOGINURL must return /mdm/certificate.");
}

- (void)testisDeviceRegistered{
    STAssertFalse([Settings isDeviceRegistered], @"isDeviceRegistered must return false");
}

- (void)testlicenseAgreed{
    [Settings licenseAgreed];
    STAssertTrue([Settings isLicenseAgreed], @"isLicenseAgreed must return true after invoking licenseAgreed");
}

- (void)testisLicenseAgreed{
    STAssertFalse([Settings isLicenseAgreed], @"isLicenseAgreed must return false");
}

- (void)testisPushedToServer{
    STAssertFalse([Settings isPushedToServer], @"isPushedToServer must return false");
}

- (void)testgetResourcePlist{
    STAssertNil([Settings getResourcePlist:@""], @"getResourcePlist:nil must return nil.");
    STAssertEqualObjects(@"www.wso2.com", [Settings getResourcePlist:SERVER_URL], @"getResourcePlist:SERVER_URL must return www.wso2.com.");
}

@end
