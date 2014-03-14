//
//  ResponseObject.h
//  MDM Agent
//
//  Created by WSO2 on 11/6/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseObject : NSObject

@property (nonatomic, assign) BOOL isSuccess;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *errorTitle;
@property (nonatomic, assign) BOOL registered;

@end
