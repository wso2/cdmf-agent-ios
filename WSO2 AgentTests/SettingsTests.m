//
//  SettingsTests.m
//  agent
//
//  Created by Dilshan on 4/25/14.
//  Copyright (c) 2014 WSO2. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Settings.h"
#import <OCMock/OCMock.h>

#define TEST_KEY @"TEST_KEY"
#define TEST_VALUE @"TEST_VALUE"


@interface SettingsTests : SenTestCase

@end

@implementation SettingsTests

- (void)setUp
{
    [super setUp];
    [Settings copyResource];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
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
    STAssertNil([Settings getDeviceUnique], @"DeviceUnique parameter must be nil on initialization");
}

- (void)testgetServerURL{
    //NSString *url = URL_PREFIX + @"";
    //STAssertNil([Settings getServerURL:@""], @"");
}

- (void)testgetEndPoint{
    STAssertNil([Settings getEndpoint:@""], @"GetEndPoint:nil must return nil.");
    STAssertEqualObjects(@"/mdm/certificate", [Settings getEndpoint:LOGINURL], @"GetEndPoint:LOGINURL must return /mdm/certificate.");
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
