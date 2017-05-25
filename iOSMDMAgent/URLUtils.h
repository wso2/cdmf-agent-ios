//
//  URLUtils.h
//  iOSMDMAgent
//


#import <Foundation/Foundation.h>

@interface URLUtils : NSObject

extern float const HTTP_REQUEST_TIME;
extern int HTTP_OK;
extern int HTTP_CREATED;
extern NSString *const ENDPOINT_FILE_NAME;
extern NSString *const EXTENSION;
extern NSString *const TOKEN_PUBLISH_URI;
extern NSString *const ENROLLMENT_URI;
extern NSString *const SERVER_URL;
extern NSString *const CONTEXT_URI;
extern NSString *const TOKEN;
extern NSString *const GET;
extern NSString *const POST;
extern NSString *const PUT;
extern NSString *const ACCEPT;
extern NSString *const CONTENT_TYPE;
extern NSString *const APPLICATION_JSON;
extern NSString *const LATITIUDE;
extern NSString *const LONGITUDE;
extern NSString *const UNENROLLMENT_PATH;
extern NSString *const AUTHORIZATION_BEARER;
extern NSString *const AUTHORIZATION_BASIC;
extern NSString *const AUTHORIZATION;
extern NSString *const REFRESH_TOKEN_URI;
extern NSString *const REFRESH_TOKEN_LABEL;
extern NSString *const GRANT_TYPE;
extern NSString *const GRANT_TYPE_VALUE;
extern NSString *const FORM_ENCODED;
extern NSString *const OPERATION_URI;
extern NSString *const OPERATION_ID_RESPOSNE;
extern NSString *const STATUS;
extern int OAUTH_FAIL_CODE;

+ (void)saveServerURL:(NSString *)serverURL;
+ (NSString *)getServerURL;
+ (NSString *)getEnrollmentURL;
+ (NSString *)getContextURL;
+ (NSDictionary *)readEndpoints;
+ (NSString *)getTokenPublishURL;
+ (NSString *)getLocationPublishURL;
+ (NSString *)getUnenrollURL;
+ (NSString *)getRefreshTokenURL;
+ (NSString *)getOperationURL;


@end
