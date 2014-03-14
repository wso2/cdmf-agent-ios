//
//  WebViewController.m
//  WSO2 Agent
//
//  Created by WSO2 on 10/8/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import "WebViewController.h"


@interface WebViewController () <RegisterDelegate> {
    ApiResponse *_manager;
    BOOL _Authenticated;
    NSURLRequest *_FailedRequest;
}

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_logo.png"]];
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,125,32)];
        [titleView addSubview:imageView];
        self.navigationItem.titleView = titleView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRegistered) name:UIApplicationWillEnterForegroundNotification object:nil];
    // Do any additional setup after loading the view from its nib.
    
    _manager = [[ApiResponse alloc] init];
    _manager.registerDelegate = self;
    
    [self.webView setDelegate:self];
    
    //NSString *webUrl = [Settings getEndpoint:@"loginurl"];
    //NSURL *url = [NSURL URLWithString:webUrl];
    //NSURL *url = [NSURL URLWithString:@"http://192.168.18.57:9763/mdm/deviceloginsign.html"];
    NSURL *url = [NSURL URLWithString:@"https://192.168.18.57:9443/mdm/deviceloginsign.html"];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestURL];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    if ([self firstDisplay]) {
        self.firstDisplay = NO;
    } else {
        [_manager isRegistered:[Settings getDeviceUnique]];
    }
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}


- (void) popToUnregister {
    
    [Settings updatePlist:DEVICEREG StringText:@"TRUE"];
    //[Settings saveRegistered: @"TRUE"];
    
    //Remove dimmed screen
    
//    NSMutableArray *viewContArray = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    UnregisterViewController *uregViewController = [[UnregisterViewController alloc] init];
//    [viewContArray replaceObjectAtIndex:0 withObject:uregViewController];
//    [self.navigationController setViewControllers:viewContArray];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:uregViewController]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) checkRegistered {
    [_manager isRegistered:[Settings getDeviceUnique]];
}

- (void) displayErrorMsgOnMain : (ResponseObject *) responseObject {
    [[[UIAlertView alloc] initWithTitle:responseObject.errorTitle message:responseObject.message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}


#pragma Delegate Calls

- (void) didReceiveRegistration:(ResponseObject *) responseObject {
    
    if (responseObject.isSuccess == FALSE) {
        [self registerFailedWithError:NULL];
    } else {
        if (responseObject.isSuccess == TRUE) {
            //Device has been registered successfully
            [self performSelectorOnMainThread:@selector(popToUnregister) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void) registerFailedWithError:(ResponseObject *) responseObject {
    [self performSelectorOnMainThread:@selector(displayErrorMsgOnMain) withObject:responseObject.message waitUntilDone:NO];
}


#pragma UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL result = _Authenticated;
    if (!_Authenticated) {
        _FailedRequest = request;
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [urlConnection start];
    }
    return result;
}


#pragma NSURLConnectionDelegate

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURL* baseURL = [NSURL URLWithString:@"https://192.168.18.57:9443"];
        if ([challenge.protectionSpace.host isEqualToString:baseURL.host]) {
            NSLog(@"trusting connection to host %@", challenge.protectionSpace.host);
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        } else
            NSLog(@"Not trusting connection to host %@", challenge.protectionSpace.host);
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)pResponse {
    _Authenticated = YES;
    [connection cancel];
    [self.webView loadRequest:_FailedRequest];
}


@end
