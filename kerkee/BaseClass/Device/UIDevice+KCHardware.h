//
//  UIDevice+Hardware.h
//  kerkee
//
//  This is device list extend from UIDeviceUtil
//  It's a device which is not listed in this category. Please visit https://github.com/InderKumarRathore/UIDeviceUtil
//  and add a comment there.
//  UIDeviceUtil is a simple lib to know the exact type of the device instead of just iPhone or iPad.
//  For Swift lib please visit DeviceGuru(https://github.com/InderKumarRathore/DeviceGuru)
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
#define DEVICE_IOS_VERSION [[UIDevice currentDevice].systemVersion floatValue]
#define DEVICE_HARDWARE_BETTER_THAN(i) [[UIDevice currentDevice] isCurrentDeviceHardwareBetterThan:i]

typedef enum
{
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown,
    
} UIDeviceFamily;

typedef enum
{
    NOT_AVAILABLE,
    
    IPHONE_2G,
    IPHONE_3G,
    IPHONE_3GS,
    IPHONE_4,
    IPHONE_4_CDMA,
    IPHONE_4S,
    IPHONE_5,
    IPHONE_5_CDMA_GSM,
    IPHONE_5C,
    IPHONE_5C_CDMA_GSM,
    IPHONE_5S,
    IPHONE_5S_CDMA_GSM,
    IPHONE_6_PLUS,
    IPHONE_6,
    
    IPOD_TOUCH_1G,
    IPOD_TOUCH_2G,
    IPOD_TOUCH_3G,
    IPOD_TOUCH_4G,
    IPOD_TOUCH_5G,
    
    IPAD,
    IPAD_2,
    IPAD_2_WIFI,
    IPAD_2_CDMA,
    IPAD_3,
    IPAD_3G,
    IPAD_3_WIFI,
    IPAD_3_WIFI_CDMA,
    IPAD_4,
    IPAD_4_WIFI,
    IPAD_4_GSM_CDMA,
    
    IPAD_MINI,
    IPAD_MINI_WIFI,
    IPAD_MINI_WIFI_CDMA,
    IPAD_MINI_RETINA_WIFI,
    IPAD_MINI_RETINA_WIFI_CDMA,
    IPAD_MINI_3_WIFI,
    IPAD_MINI_3_WIFI_CELLULAR,
    IPAD_MINI_RETINA_WIFI_CELLULAR_CN,
    
    IPAD_AIR_WIFI,
    IPAD_AIR_WIFI_GSM,
    IPAD_AIR_WIFI_CDMA,
    IPAD_AIR_2_WIFI,
    IPAD_AIR_2_WIFI_CELLULAR,
    
    SIMULATOR
} KCHardware;


@interface UIDevice (KCHardware)
/** This method retruns the hardware type */
- (NSString*)hardwareString;

/** This method returns the Hardware enum depending upon harware string */
- (KCHardware)hardware;

/** This method returns the readable description of hardware string */
- (NSString*)hardwareDescription;

/** This method returs the readble description without identifier (GSM, CDMA, GLOBAL) */
- (NSString *)hardwareSimpleDescription;

/**
 This method returns the hardware number not actual but logically.
 e.g. if the hardware string is 5,1 then hardware number would be 5.1
 */
- (float)hardwareNumber:(KCHardware)hardware;

/** This method returns the resolution for still image that can be received
 from back camera of the current device. Resolution returned for image oriented landscape right. **/
- (CGSize)backCameraStillImageResolutionInPixels;


/** This method returns YES if the current device is better than the hardware passed */
- (BOOL)isCurrentDeviceHardwareBetterThan:(KCHardware)hardware;

//#pragma mark -
- (NSString *) platform;
- (NSString *) hwmodel;

- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) cpuCount;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (NSString *) macaddress;

- (BOOL) hasRetinaDisplay;
- (UIDeviceFamily) deviceFamily;
@end
