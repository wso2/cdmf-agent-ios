//
//  ResponseDelegate.h
//  WSO2 Agent
//
//  Created by WSO2 on 10/7/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseObject.h"

@protocol ResponseDelegate

- (void) licenseWithError : (ResponseObject *) responseObject;
- (void) getLicense: (ResponseObject *) responseObject;

@end
