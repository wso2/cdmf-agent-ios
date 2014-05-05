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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Settings.h"
#import "ResponseObject.h"
#import "ResponseBuilder.h"
#import "ResponseObject.h"

#import "RegisterDelegate.h"
#import "ResponseDelegate.h"
#import "UnregisterDelegate.h"
#import "PushDelegate.h"

@interface ApiResponse : NSObject

//Delegates
@property (weak, nonatomic) id<RegisterDelegate> registerDelegate;
@property (weak, nonatomic) id<ResponseDelegate> responseDelegate;
@property (weak, nonatomic) id<UnregisterDelegate> unregisterDelegate;
@property (weak, nonatomic) id<PushDelegate> pushDelegate;

typedef void (^NSURLCompletionBlock)(ResponseObject *obj, BOOL success);

- (void) isRegistered: (NSString *) uniqueID withCallback:(NSURLCompletionBlock) callback;
- (void) getLicense :(NSURLCompletionBlock)callback;
- (void) unregisterFromMDM: (NSString *) uniqueID withCallback:(NSURLCompletionBlock)callback;
- (void) sendPushTokenToServer: (NSString *) pushToken UDID: (NSString *) udid withCallback:(NSURLCompletionBlock)callback;
- (void) sendLocationToServer: (CLLocation *)location withCallback:(NSURLCompletionBlock)callback;

@end
