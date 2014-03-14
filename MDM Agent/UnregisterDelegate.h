//
//  UnregisterDelegate.h
//  WSO2 Agent
//
//  Created by WSO2 on 10/8/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseObject.h"

@protocol UnregisterDelegate

- (void) onSuccessUnregister: (ResponseObject *) responseObject;
- (void) unregisterFailedWithError: (ResponseObject *) responseObject;

@end
