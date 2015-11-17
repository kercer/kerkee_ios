//
//  KCWidget.m
//  SHFDemo
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCWidget.h"
#import "KCJSBridge.h"
#import "KCSDKJSDefine.h"
#import "KCBaseDefine.h"

//#import "UIView+Toast.h"

@implementation KCWidget

+ (void)toast:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSString *tostStr = [aArgList toString];
    if(nil == tostStr)
        return;
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KCWidget toast" message:tostStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    //KCRelease(alert);

//    [aWebView makeToast:tostStr];
}
+ (void)commonApi:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSString* jsonInfo = [aArgList getObject:@"info"];
    NSLog(@"%@", jsonInfo);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"OK!" forKey:@"info"];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
    //返回
    
    NSString *callbackId = [aArgList getObject:kKerkeeSDK_CallbackId];
    if(nil == callbackId)
        return;
    [KCJSBridge callbackJS:aWebView callBackID:callbackId jsonString:json];
}
+ (void)onSetImage:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSLog(@"KCWidget onSetImage");
}
+ (void)showDialog:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSString *tostStr = [aArgList toString];
    if(nil == tostStr)
        return;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KCWidget showDialog" message:tostStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    KCRelease(alert);
}
+ (void)alertDialog:(KCWebView *)aWebView argList:(KCArgList *)aArgList
{
    NSString *tostStr = [aArgList toString];
    if(nil == tostStr)
        return;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KCWidget alertDialog" message:tostStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    KCRelease(alert);
}

/*
public static void toast(final KCWebView aWebView, KCArgList aArgList) {
    String str = aArgList.toString();
    Toast.makeText(aWebView.getContext(), str, Toast.LENGTH_SHORT).show();
    if (KCLog.DEBUG)
        KCLog.d(">>>>>> NewApiTest testJSBrige called: "
                + aArgList.toString());
}

public static void commonApi(final KCWebView aWebView, KCArgList aArgList) {
    if (KCLog.DEBUG)
        KCLog.d(">>>>>> NewApiTest commonApi called: "
                + aArgList.toString());
    String callbackId = (String) aArgList.getArgValue(KCJSDefine.kJS_callbackId);
    JSONObject jsonObject = null;
    try {
        jsonObject = new JSONObject("{'key'='value'}");
    } catch (JSONException e) {
        e.printStackTrace();
    }
    KCJSBridge.callbackJS(aWebView, callbackId, jsonObject);
}

public static void onSetImage(final KCWebView aWebView, KCArgList aArgList) {
    if (KCLog.DEBUG)
        KCLog.d(">>>>>> NewApiTest onSetImage called: "
                + aArgList.toString());
}

public static void showDialog(final KCWebView aWebView, KCArgList aArgList) {
    String jsonStr = aArgList.toString();
    final String callbackId = (String) aArgList.getArgValue(KCJSDefine.kJS_callbackId);
    KCLog.d(">>>>>> NewApiTest showDialog called: " + callbackId+",jsonStr>>>>>"+jsonStr);
    
    String title = aArgList.getString("title");
    String message = aArgList.getString("message");
    String okBtn=aArgList.getString("okBtn");
    String cancelBtn=aArgList.getString("cancelBtn");
    
    AlertDialog.Builder builder = new AlertDialog.Builder(
                                                          aWebView.getContext());
    builder.setTitle(title);
    builder.setMessage(message);
    builder.setPositiveButton(okBtn, new DialogInterface.OnClickListener() {
        public void onClick(DialogInterface dialog, int whichButton) {
            if (KCLog.DEBUG){
                KCLog.d(">>>>>> NewApiTest showDialog called: PositiveButton click");
            }
            KCJSBridge.callbackJS(aWebView, callbackId,"1");
        }
    });
    
    builder.setNegativeButton(cancelBtn, new DialogInterface.OnClickListener() {
        public void onClick(DialogInterface dialog, int whichButton) {
            if (KCLog.DEBUG)
                KCLog.d(">>>>>> NewApiTest showDialog called: NegativeButton click");
            KCJSBridge.callbackJS(aWebView, callbackId,"0");
        }
    });
    
    builder.show();
}

public static void alertDialog(final KCWebView aWebView, KCArgList aArgList) {
    String jsonStr = aArgList.toString();
    final String callbackId = (String) aArgList.getArgValue(KCJSDefine.kJS_callbackId);
    KCLog.d(">>>>>> NewApiTest showDialog called: " + callbackId);
    
 
    String title = aArgList.getString("title");
    String message = aArgList.getString("message");
    String okBtn=aArgList.getString("okBtn");
    String cancelBtn=aArgList.getString("cancelBtn");
    
    AlertDialog.Builder builder = new AlertDialog.Builder(
                                                          aWebView.getContext());
    builder.setTitle(title);
    builder.setMessage(message);
    builder.setPositiveButton(okBtn, new DialogInterface.OnClickListener() {
        public void onClick(DialogInterface dialog, int whichButton) {
            if (KCLog.DEBUG){
                KCLog.d(">>>>>> NewApiTest showDialog called: PositiveButton click");
            }
            KCJSBridge.callbackJS(aWebView, callbackId,"1");
        }
    });
    
    
    builder.show();
}
*/
@end
