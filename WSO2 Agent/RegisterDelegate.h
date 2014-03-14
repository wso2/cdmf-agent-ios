//
//  RegisterDelegate.h
//  WSO2 Agent
//
//  Created by WSO2 on 10/8/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseObject.h"

@protocol RegisterDelegate

- (void) didReceiveRegistration: (ResponseObject *) responseObject;
- (void) registerFailedWithError: (ResponseObject *) responseObject;

@end
