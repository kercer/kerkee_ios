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
    m_webView.delegate = self;
    [self.view addSubview:m_webView];
    
    m_jsBridge = [[KCJSBridge alloc] initWithWebView:m_webView delegate:self];
    
    

//    NSString* pathTestHtml = [[NSBundle mainBundle] pathForResource:@"test.html" ofType:Nil];
//    NSURL* url =[NSURL URLWithString:pathTestHtml];
    
    NSURL* url =[NSURL URLWithString:KCWebPath_ModulesChannel_File];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [m_webView loadRequest:request];
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
   
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   
    return YES;
}

@end
