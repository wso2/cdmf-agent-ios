//
//  ResponseBuilder.h
//  WSO2 Agent
//
//  Created by WSO2 on 11/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseObject.h"
#import "Settings.h"

@interface ResponseBuilder : NSObject

//+ (ResponseObject *)getStringFromJSON: (NSData *) data requestHeader: (NSString *) request;
+ (ResponseObject *) httpResponse: (NSURLResponse *) response body: (NSData *) data error: (NSError **) error requestHeader: (NSString *) request;

@end
