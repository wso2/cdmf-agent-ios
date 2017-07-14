//
//  SDKProtocol.h
//  iOSMDMAgent


#import <Foundation/Foundation.h>

@protocol SDKProtocol <NSObject>

@optional

- (void)unregisterSuccessful;
- (void)unregisterFailure:(NSError *)error;

@end
