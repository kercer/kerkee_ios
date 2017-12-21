//
//  ViewController.m
//  kerkeeExample
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "ViewController.h"
#import "kerkee.h"
#import "KCRegistMgr.h"
#import "KCHelper.h"
#import "KCBaseDefine.h"
#import "KCWebPathDefine.h"
#import "KCURIComponents.h"
#import "KCActionTest.h"
#import "KCUriRegister.h"
#import "KCUriDispatcher.h"
#import "KCFetchManifest.h"
#import "KCJSCompileExecutor.h"


@interface ViewController ()
{
    KCWebView* m_webView;
    KCJSBridge* m_jsBridge;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //addSkipBackupAttributeToItemAtURL
    
    KCHelper* helper = [[KCHelper alloc] init];
    KCRelease(helper);
    [helper unzipHtml];
    
    [KCRegistMgr registAllClass];
    KCLog(@"docment dir:\n%@",KCWebPath_HtmlRootPath);
    
    m_webView = [[KCWebView alloc] initWithFrame:self.view.bounds usingUIWebView:NO];
    //add webview in your view
    [self.view addSubview:m_webView];
    //you can implement webview delegate
    m_jsBridge = [[KCJSBridge alloc] initWithWebView:m_webView delegate:self];

    //add custom UserAgent, you can set your UserAgent
    m_webView.customUserAgent = @"kerkee/1.0.0";

//    NSString* pathTestHtml = [[NSBundle mainBundle] pathForResource:@"test.html" ofType:Nil];
//    pathTestHtml = [NSString stringWithFormat:@"file://%@", pathTestHtml];
//    NSURL* url =[NSURL URLWithString:pathTestHtml];
    NSURL* url =[NSURL URLWithString:KCWebPath_ModulesTest_File];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [m_webView loadRequest:request];
    
//    [self testFetchManifest];
    //test action
//    [self testAction];
}


-(void)testAction
{
    KCUriRegister* uriRegister = [KCUriDispatcher markDefaultRegister:@"kerkee"];
//    KCUriRegister* uriRegister = [KCUriDispatcher defaultUriRegister];
    KCActionTest* action = [[KCActionTest alloc] init];
    [uriRegister registerAction:action];
    
    [KCUriDispatcher dispatcher:@"kerkee://search/path?A=1&B=2&C=3&D=4"];
}


-(void)testFetchManifest
{
    KCURI* uriServer = [KCURI parse:@"http://www.linzihong.com/test/html/manifest"];
    [KCFetchManifest fetchOneServerManifest:uriServer block:^(KCManifestObject *aManifestObject) {
    }];
    [KCFetchManifest fetchServerManifests:uriServer block:^(KCManifestObject *aManifestObject) {
        
        KCLog(@"%@", aManifestObject);
    }];
    
    
    KCURI* uriLocal = [KCURI parse:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/html"] stringByAppendingPathComponent:@"manifest"]];
//    [KCFetchManifest fetchOneLocalManifest:uriLocal block:^(KCManifestObject *aManifestObject)
//    {
//        KCLog(@"%@", aManifestObject);
//    }];
    
    [KCFetchManifest fetchLocalManifests:uriLocal block:^(KCManifestObject *aManifestObject) {
        KCLog(@"%@", aManifestObject);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --
#pragma mark KCWebViewProgressDelegate

-(void)webView:(KCWebView*)webView identifierForInitialRequest:(NSURLRequest*)initialRequest
{
}

#pragma mark - UIWebView Delegate
- (void)webViewDidFinishLoad:(KCWebView *)aWebView
{
//    NSString *scrollHeight = [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
//    NSLog(@"scrollHeight: %@", scrollHeight);
    NSLog(@"webview.contentSize.height %f", aWebView.scrollView.contentSize.height);
//    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:aWebView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[scrollHeight floatValue]];
    
//    [aWebView addConstraint:heightConstraint];
    NSLog(@"webview frame %@", NSStringFromCGRect(aWebView.frame));
    
    
    [m_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        NSLog(@"%@", result);
    }];

}

- (void)webView:(KCWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (BOOL)webView:(KCWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", request.URL.absoluteString);
    return YES;
}


@end
