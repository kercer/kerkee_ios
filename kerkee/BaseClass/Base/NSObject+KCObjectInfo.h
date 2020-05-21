//
//  NSObject+KCObjectInfo.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define KC_VALUE(struct) ({ __typeof__(struct) __struct = struct; [NSValue valueWithBytes:&__struct objCType:@encode(__typeof__(__struct))]; })

#define KC_MAKELIVE(_CLASSNAME_)	Class _CLASSNAME_ = NSClassFromString((NSString *)CFSTR(#_CLASSNAME_));

#define KC_VERIFIED_CLASS(_CLASSNAME_) ((_CLASSNAME_ *) NSClassFromString(@"" # _CLASSNAME_))


typedef IMP *IMPPointer;
BOOL class_swizzleMethodAndStore(Class aClass, SEL aOriginal, IMP aReplacement, IMPPointer aStore);

@interface NSObject (KCObjectInfo)

// A work in progress
+ (NSString *) kc_typeForString: (const char *) aTypeName;

// Return all superclasses of class or object
+ (NSArray *) kc_superclasses;
- (NSArray *) kc_superclasses;

// Examine
+ (NSString *) kc_dump;
- (NSString *) kc_dump;

// Access to object essentials for run-time checks. Stored by class in dictionary.
// Return an array of all an object's selectors
+ (NSArray *) kc_getMetaSelectorListForClass;
+ (NSArray *) kc_getSelectorListForClass;
+ (NSArray *) kc_getPropertyListForClass;
+ (NSArray *) kc_getIvarListForClass;
+ (NSArray *) kc_getProtocolListForClass;



// Return a dictionary with class/selectors entries, all the way up to NSObject
@property (readonly) NSDictionary *kc_selectors;
@property (readonly) NSDictionary *kc_properties;  //you can see KCProperty class
@property (readonly) NSDictionary *kc_ivars;
@property (readonly) NSDictionary *kc_protocols;

// Check for properties, ivar. Use respondsToSelector: and conformsToProtocol: as well
- (BOOL) kc_hasProperty: (NSString *) aPropertyName;
- (BOOL) kc_hasIvar: (NSString *) aIvarName;
+ (BOOL) kc_classExists: (NSString *) aClassName;
+ (id) kc_instanceOfClassNamed: (NSString *) aClassName;

+ (void)kc_swizzleMethod:(SEL)aOrigSel withMethod:(SEL)aAltSel;
+ (BOOL)kc_swizzle:(SEL)aOriginal with:(IMP)aReplacement store:(IMPPointer)aStore;
+ (void)kc_exchangeMethond:(SEL)aSel1 :(SEL)aSel2;
+(IMP)kc_replaceMethod :(SEL)aOldMethond :(IMP)aNewIMP;

@end


// Method swizzling
void KCSwapClassMethods(Class cls, SEL original, SEL replacement);
void KCSwapInstanceMethods(Class cls, SEL original, SEL replacement);

// Module subclass support
BOOL KCClassOverridesClassMethod(Class cls, SEL selector);
BOOL KCClassOverridesInstanceMethod(Class cls, SEL selector);


