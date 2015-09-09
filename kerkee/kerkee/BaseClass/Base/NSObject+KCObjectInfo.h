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

#define KC_VALUE(struct) ({ __typeof__(struct) __struct = struct; [NSValue valueWithBytes:&__struct objCType:@encode(__typeof__(__struct))]; })

#define KC_MAKELIVE(_CLASSNAME_)	Class _CLASSNAME_ = NSClassFromString((NSString *)CFSTR(#_CLASSNAME_));

#define KC_VERIFIED_CLASS(_CLASSNAME_) ((_CLASSNAME_ *) NSClassFromString(@"" # _CLASSNAME_))

@interface NSObject (KCObjectInfo)

// A work in progress
+ (NSString *) typeForString: (const char *) aTypeName;

// Return all superclasses of class or object
+ (NSArray *) superclasses;
- (NSArray *) superclasses;

// Examine
+ (NSString *) dump;
- (NSString *) dump;

// Access to object essentials for run-time checks. Stored by class in dictionary.
// Return an array of all an object's selectors
+ (NSArray *) getSelectorListForClass;
+ (NSArray *) getPropertyListForClass;
+ (NSArray *) getIvarListForClass;
+ (NSArray *) getProtocolListForClass;

// Return a dictionary with class/selectors entries, all the way up to NSObject
@property (readonly) NSDictionary *selectors;
@property (readonly) NSDictionary *properties;  //you can see KCProperty class
@property (readonly) NSDictionary *ivars;
@property (readonly) NSDictionary *protocols;

// Check for properties, ivar. Use respondsToSelector: and conformsToProtocol: as well
- (BOOL) hasProperty: (NSString *) aPropertyName;
- (BOOL) hasIvar: (NSString *) aIvarName;
+ (BOOL) classExists: (NSString *) aClassName;
+ (id) instanceOfClassNamed: (NSString *) aClassName;


@end
