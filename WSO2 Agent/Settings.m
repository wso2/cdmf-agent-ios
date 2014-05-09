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
 * 	Description : - Class with Utility methods
 */

#import "Settings.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation Settings

+ (NSString *) getDeviceUnique {
    NSString *uniqueID ;
    uniqueID = [self getResourcePlist:DEVICE_UDID];
    return uniqueID;
}


+ (NSString *) getMacAddress {
    
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL) {
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+ (NSString *) getServerURL: (NSString *) resourcename {
    
    NSString *endpoint = URL_PREFIX;
    endpoint = [endpoint stringByAppendingString:[self getResourcePlist:SERVER_URL]];
    endpoint = [endpoint stringByAppendingString:PORT];
    endpoint = [endpoint stringByAppendingString:[self getEndpoint:resourcename]];
    return endpoint;
}

+ (NSString *) getEndpoint:(NSString *)resourcename {
    NSDictionary *list = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Endpoints" ofType:@"plist"]];
     return [list objectForKey:resourcename];
}

+ (BOOL) isDeviceRegistered {
    NSString *deviceRegistered = [self getResourcePlist:DEVICEREG];
    if (deviceRegistered == NULL)
        return FALSE;
    else if ([deviceRegistered isEqualToString:@"FALSE"])
        return FALSE;
    else
        return TRUE;
}

+ (BOOL) isLicenseAgreed {
    NSString *deviceRegistered = [self getResourcePlist:ISLICENSEAGREED];
    if (deviceRegistered == NULL)
        return FALSE;
    else if ([deviceRegistered isEqualToString:@"FALSE"])
        return FALSE;
    else
        return TRUE;
}

+ (BOOL) isPushedToServer {
    NSString *deviceRegistered = [self getResourcePlist:PUSHTOKENTOSERVER];
    if (deviceRegistered == NULL)
        return FALSE;
    else if ([deviceRegistered isEqualToString:@"FALSE"])
        return FALSE;
    else
        return TRUE;
}

+ (void) copyResource {
    BOOL success;
    NSError *error;
    NSString *resourceFile = RESOURCE_PLIST;
    resourceFile = [resourceFile stringByAppendingString:@".plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:resourceFile];
    success = [fileManager fileExistsAtPath:filePath];
    if (success) return;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:RESOURCE_PLIST ofType:@"plist"];
    [fileManager copyItemAtPath:path toPath:filePath error:&error];
}

+ (NSString *) getResourcePlist: (NSString *) objectKey {
    NSString *filePath = RESOURCE_PLIST;
    filePath = [filePath stringByAppendingString:@".plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =  [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:filePath];
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *value = (NSString *) [plistDict objectForKey:objectKey];
    return value;
}

+ (void) updatePlist: (NSString *) listKey StringText: (NSString *) stringValue {
    
    NSString *filePath = RESOURCE_PLIST;
    filePath = [filePath stringByAppendingString:@".plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =  [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:filePath];
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [plistDict setValue:stringValue forKey:listKey];
    [plistDict writeToFile:plistPath atomically:YES];
}


 
+ (void) licenseAgreed {
    NSString *filePath = RESOURCE_PLIST;
    filePath = [filePath stringByAppendingString:@".plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory =  [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:filePath];
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [plistDict setValue:@"TRUE" forKey:ISLICENSEAGREED];
    [plistDict writeToFile:plistPath atomically:YES];
}

@end
