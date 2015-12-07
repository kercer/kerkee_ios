//
//  ViewController.m
//  kerkeeDemo
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import "ViewController.h"
#import "kerkee.h"
#import "KCChannelModuleApi.h"
#import "KCRegistMgr.h"
#import "KCAssistant.h"
#import "KCBaseDefine.h"
#import "KCWebPathDefine.h"
#import "KCURIComponents.h"
#import "KCActionTest.h"
#import "KCUriRegister.h"
#import "KCUriDispatcher.h"


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
    
    KCAssistant* assistant = [[KCAssistant alloc] init];
    KCRelease(assistant);
    
    [KCRegistMgr registAllClass];
    
    KCLog(@"docment dir:\n%@",KCWebPath_HtmlRootPath);
    
    m_webView = [[KCWebView alloc] initWithFrame:self.view.bounds];
//    m_webView.delegate = self;
    [self.view addSubview:m_webView];
    
    m_jsBridge = [[KCJSBridge alloc] initWithWebView:m_webView delegate:self];
    
    
//    //test uri
//    KCURIComponents *components = [KCURIComponents componentsWithURL:[NSURL URLWithString:@"scheme://user:password@host:0/path?query=1&q=2#fragment"]
//                                             resolvingAgainstBaseURL:NO];

    

//    NSString* pathTestHtml = [[NSBundle mainBundle] pathForResource:@"test.html" ofType:Nil];
//    NSURL* url =[NSURL URLWithString:pathTestHtml];
    
    NSURL* url =[NSURL URLWithString:KCWebPath_ModulesTest_File];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [m_webView loadRequest:request];
    
    
    
    //test action
    [self testAction];
}


-(void)testAction
{
    KCUriRegister* uriRegister = [KCUriDispatcher markDefaultRegister:@"kerkee"];
//    KCUriRegister* uriRegister = [KCUriDispatcher defaultUriRegister];
    KCActionTest* action = [[KCActionTest alloc] init];
    [uriRegister registerAction:action];
    
    [KCUriDispatcher dispatcher:@"kerkee://search/path?A=1&B=2&C=3&D=4"];
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

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    NSString *scrollHeight = [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    NSLog(@"scrollHeight: %@", scrollHeight);
    NSLog(@"webview.contentSize.height %f", aWebView.scrollView.contentSize.height);
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:aWebView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[scrollHeight floatValue]];
//    [aWebView addConstraint:heightConstraint];
    NSLog(@"webview frame %@", NSStringFromCGRect(aWebView.frame));
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   
    return YES;
}


@end
