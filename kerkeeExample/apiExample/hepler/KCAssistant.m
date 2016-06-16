//
//  SHFAssistant.m
//  SHFDemo
//
//  Created by lijian on 15/8/25.
//  Copyright (c) 2015年 lijian. All rights reserved.
//

#import "KCAssistant.h"
#import "KCWebView.h"
#import "KCWebPathDefine.h"
#import "ZipArchive.h"
#import "KCBaseDefine.h"
#import "KCFileManager.h"

@interface KCAssistant()
{
    KCWebView *m_webView;
    
}

@end

@implementation KCAssistant

- (id)init
{
    self = [super init];
    if(self)
    {
        [self createRootPath];
    }
    return self;
}

- (void)dealloc
{
    KCDealloc(super);
}

- (void)createRootPath
{
    [[NSFileManager defaultManager] removeItemAtPath:KCWebPath_HtmlRootPath error:nil];
    
    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:KCWebPath_HtmlRootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:KCWebPath_HtmlRootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [self updateTemplateFile];
}


- (void)updateTemplateFile
{
    NSString *zipBundlePath = [self getTemplateZipBundlePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipBundlePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:KCWebPath_HtmlRootPath error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:KCWebPath_HtmlRootPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        [[NSFileManager defaultManager] removeItemAtPath:KCWebPath_HtmlRootPath_ZipFile error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:zipBundlePath toPath:KCWebPath_HtmlRootPath_ZipFile error:nil];
        
        [self unzipUpdateTemplateFile];
    }
}

- (NSString *)getTemplateZipBundlePath
{
    return [[NSBundle mainBundle] pathForResource:@"html" ofType:@"zip"];;
    //return [[NSBundle mainBundle] pathForResource:@"html5_templet_release" ofType:@"zip"];;
}


- (void)unzipUpdateTemplateFile
{
    NSString* zipPath = nil;
    BOOL isDirectory = NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:KCWebPath_HtmlRootPath_ZipFile isDirectory:&isDirectory]) {
        zipPath = KCWebPath_HtmlRootPath_ZipFile;
    } else {
        return;
    }
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    zipArchive.delegate = (id)self;
    
    if ([zipArchive UnzipOpenFile:zipPath]) {
        if([zipArchive UnzipFileTo:KCWebPath_HtmlLocalPath overWrite:YES]){
            [zipArchive UnzipCloseFile];
            [[NSFileManager defaultManager] removeItemAtPath:KCWebPath_HtmlRootPath_ZipFile error:nil];
        }
    }
    
    KCRelease(zipArchive);
    
    [KCFileManager addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:KCWebPath_HtmlRootPath]];
}


- (void)loadUrl:(NSURL *)aUrl
{
    if(nil == aUrl || [aUrl.path length] <= 0)
        return;
    
    if(nil == m_webView)
        return;
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:aUrl];
    [m_webView loadRequest:request];
}

/*
protected KCWebView mWebView = null;
private KCJSBridge mJSBridge = null;
private static KCWebPath mWebpath = null;
private static String mCopySuccessFileFlag = null;

public SHFAssistant(Context context, KCWebView webView) {
    mWebView = webView;
    mJSBridge = new KCJSBridge(mWebView);
    // registClass("widget", KCWidget.class);
    registClass("platform", KCPlatform.class);
}

public static void init(final Context context) {
    mWebpath = new KCWebPath(context);
    mCopySuccessFileFlag = mWebpath.getRootPath()+"/ok.txt";
    File file = new File(mCopySuccessFileFlag);
    if (!file.exists()) {
        KCTaskExecutor.executeTask(new Runnable(){
            
            @Override
            public void run() {
                KCLog.d("SHFAssistant.init: h5 model not exist, start to copy from asset");
                copyAssetHtmlZipFile(context);
            }
            
        });
    } else {
        KCLog.d("SHFAssistant.init: h5 model exist, refuse copy");
    }
    //        KCUpgradeManager.checkUpgrade(context);
}

private static void copyAssetHtmlDir(Context context)
{
    KCAssetTool assetTool = new KCAssetTool(context);
    try
    {
        assetTool.copyDir("html.zip", mWebpath.getResRootPath());
        new File(mCopySuccessFileFlag).createNewFile();
        KCLog.d("SHFAssistant.init: h5 model copy end...");
    }
    catch (IOException e)
    {
        KCLog.d("SHFAssistant.init: h5 model copy failed...");
        e.printStackTrace();
    } finally{
    }
}

private static void copyAssetHtmlZipFile(Context context)
{
    KCAssetTool assetTool = new KCAssetTool(context);
    try
    {
        assetTool.createDir(new File(mWebpath.getRootPath()));
        assetTool.copyAssetFile("html.zip", mWebpath.getRootPath()+"/html.zip");
        new File(mCopySuccessFileFlag).createNewFile();
        KCLog.d("SHFAssistant.init: h5 model copy end...");
        unZipH5Model(mWebpath.getRootPath()+"/html.zip", mWebpath.getRootPath());
    }
    catch (IOException e)
    {
        KCLog.d("SHFAssistant.init: h5 model copy failed...");
        e.printStackTrace();
    } finally{
    }
}

private static void unZipH5Model(String zipFileString, String outPathString){
    try {
        KCLog.d("SHFAssistant.unZipH5Model: h5 model unzip start...");
        KCXZip.UnZipFolder(zipFileString,outPathString);
        KCLog.d("SHFAssistant.unZipH5Model: h5 model unzip end...");
        new File(zipFileString).delete();
        KCLog.d("SHFAssistant.unZipH5Model: h5 model zip file is deleted...");
    } catch (Exception e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
    }
}

public void loadUrl(String aUrl) {
    KCLog.d("SHFAssistant.loadUrl aUrl>>>" + aUrl);
    if (null == mWebView || TextUtils.isEmpty(aUrl))
        return;
    if (aUrl.startsWith("http://") || aUrl.startsWith("https://") || aUrl.startsWith("file://")) {
        KCLog.d("SHFAssistant.loadUrl aUrl can be loaded directly");
    } else {
        aUrl = "file://" + mWebView.getWebPath().getResRootPath()
        + "/" + aUrl;
        KCLog.d("SHFAssistant.loadUrl aUrl is a relative path,after handle aUrl>>>"+aUrl);
    }
    mWebView.loadUrlExt(aUrl);
}

public boolean registJSBridgeClient(Class<?> aClass) {
    return mJSBridge.registJSBridgeClient(aClass);
}

public boolean registClass(KCClass aClass) {
    return KCJSBridge.registClass(aClass);
}

public static boolean registClass(String aJSObjectName, Class<?> aClass) {
    return KCJSBridge.registClass(aJSObjectName, aClass);
}

public static void removeClass(String aJSObjectName) {
    KCJSBridge.removeClass(aJSObjectName);
}

public static void callJSOnMainThread(final KCWebView aWebview,
                                      final String aJS) {
    KCJSBridge.callJSOnMainThread(aWebview, aJS);
}

public static void callJS(final KCWebView aWebview, final String aJS) {
    KCJSBridge.callJS(aWebview, aJS);
}

public static void callJSFunctionOnMainThread(final KCWebView aWebview,
                                              String aFunName, String aArgs) {
    KCJSBridge.callJSFunctionOnMainThread(aWebview, aFunName, aArgs);
}

public static void callbackJS(KCWebView aWebview, String aCallbackId) {
    KCJSBridge.callbackJS(aWebview, aCallbackId);
}

public static void callbackJS(KCWebView aWebview, String aCallbackId,
                              String aStr) {
    KCJSBridge.callbackJS(aWebview, aCallbackId, aStr);
}

public static void callbackJS(KCWebView aWebview, String aCallbackId,
                              JSONObject aJSONObject) {
    KCJSBridge.callbackJS(aWebview, aCallbackId, aJSONObject);
}

public static void callbackJS(KCWebView aWebview, String aCallbackId,
                              JSONArray aJSONArray) {
    KCJSBridge.callbackJS(aWebview, aCallbackId, aJSONArray);
}

public KCWebView getWebView() {
    return mWebView;
}

public String getResRootPath() {
    return mWebView.getWebPath().getResRootPath();
}

public void destroy() {
    mJSBridge.destroy();
}

public void clearCacheFolder(){
    KCTaskExecutor.executeTask(new Runnable(){
        
        @Override
        public void run() {
            int clearNum = clearCacheFolder(new File(mWebView.getWebPath().getWebImageCachePath()),System.currentTimeMillis());
            KCLog.d("SHFAssistant.clearCacheFolder clearNum:"+clearNum);
        }
        
    });
}
// clear the cache before time numDays
private int clearCacheFolder(File dir, long numDays) {
    int deletedFiles = 0;
    if (dir != null && dir.isDirectory()) {
        try {
            for (File child : dir.listFiles()) {
                if (child.isDirectory()) {
                    deletedFiles += clearCacheFolder(child, numDays);
                }
                if (child.lastModified() < numDays) {
                    if (child.delete()) {
                        deletedFiles++;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    return deletedFiles;
}

*/

@end
