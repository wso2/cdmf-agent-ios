//
//  PushDelegate.h
//  WSO2 Agent
//
//  Created by WSO2 on 12/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseObject.h"

@protocol PushDelegate <NSObject>

- (void) onSuccessPushToken: (ResponseObject *) responseObject;
- (void) connectionError: (ResponseObject *) responseObject;

@end
