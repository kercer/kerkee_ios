//
//  NSObject+KCProperty.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@interface NSObject (KCProperty)

//return the properties dictionary, and the key is property name, the value is class type
- (NSDictionary*)propertyTypeDic;


@end


@interface NSObject (KCAddProperty)


#pragma mark

#pragma mark KCAddProperty
/**
 The KCAssociantionPolicy enum determines the association memory management type.
 */

typedef enum
{
    EPolicy_Assign = OBJC_ASSOCIATION_ASSIGN,
    EPolicy_Retain_Nonatomic = OBJC_ASSOCIATION_RETAIN_NONATOMIC,
    EPolicy_Copy_Nonatomic = OBJC_ASSOCIATION_COPY_NONATOMIC,
    EPolicy_Retain = OBJC_ASSOCIATION_RETAIN,
    EPolicy_Copy = OBJC_ASSOCIATION_COPY
}KCAssociantionPolicy;

/**
 Sets the association between any property for a specific key.
 
 @param property - the associated object
 @param key - the key to identify the associated object
 @param policy - the memory management policy
 */
- (void)setProperty:(id)aProperty forKey:(char const * const)aKey withPolicy:(KCAssociantionPolicy)aPolicy;

/**
 returns the associated object for a given key.
 
 @param key - the key to identify the associated object
 @return the assiciated object
 */
- (id)getPropertyForKey:(char const * const)aKey;

/**
 determines if there is a object for a given key.
 it handle Associated property only
 
 @param key - the key to identify the associated object
 @return a boolean value indicating if there is a associated object for a given key
 */
- (BOOL)hasPropertyForKey:(char const * const)aKey;


@end



#pragma mark KCProperties
//can not handle Add Property

// type notes:
// I'm not 100% certain what @encode(NSString) would return. @encode(id) returns '@',
// and the types of properties are actually encoded as such along with a strong-type
// value following. Therefore, if you want to check for a specific class, you can
// provide a type string of '@"NSString"'. The following macro will do this for you.
#define statictype(x)	"@\"" #x "\""

// Also, note that the runtime information doesn't include an atomicity hint, so we
// can't determine that information

@interface NSObject (KCProperties)

+ (BOOL)isPropertyReadOnly:(NSString*)aName;
+ (BOOL) hasProperties;
+ (BOOL) hasPropertyNamed: (NSString*) aName;
+ (BOOL) hasPropertyNamed: (NSString*) aName ofType: (const char*) aType;	// an @encode() or statictype() type string
+ (BOOL) hasPropertyForKVCKey: (NSString*) aKey;
+ (Class)classOfPropertyNamed:(NSString*)aPropertyName;
+ (const char *) typeOfPropertyNamed: (NSString*) aName;	// returns an @encode() or statictype() string. Copy to keep
+ (SEL) getterForPropertyNamed: (NSString*) aName;
+ (SEL) setterForPropertyNamed: (NSString*) aName;
+ (NSString*) retentionMethodOfPropertyNamed: (NSString*) aName;		// returns one of: copy, retain, assign
+ (NSArray*) propertyNames;
+ (NSArray *)propertyNamesWithClass:(Class)aCls;
+ (NSArray*) namesForPropertiesOfClass:(Class)aCls;

- (NSString*)propertyStyleString:(NSString*)aString;
- (BOOL)isPropertyReadOnly:(NSString*)aName;
// instance convenience accessors for above routines (who likes to type [myObj class] all the time ?)
- (BOOL) hasProperties;
- (BOOL) hasPropertyNamed: (NSString*) aName;
- (BOOL) hasPropertyNamed: (NSString*) aName ofType: (const char *) aType;
- (BOOL) hasPropertyForKVCKey: (NSString*) aKey;
- (const char *) typeOfPropertyNamed: (NSString*) aName;
- (Class)classOfPropertyNamed:(NSString*) aPropertyName;
- (SEL) getterForPropertyNamed: (NSString*) aName;
- (SEL) setterForPropertyNamed: (NSString*) aName;
- (NSString*) retentionMethodOfPropertyNamed: (NSString*) aName;
- (NSArray*) propertyNames;
- (NSArray*) namesForPropertiesOfClass:(Class)aCls;

@end


typedef NSObject KCPropertiesUseCache;
@interface NSObject (KCPropertiesUseCache)
+ (NSArray *)propertyNamesAllClass:(Class)aCls;
+ (Class)propertyClassAllForPropertyName:(NSString *)propertyName ofClass:(Class)aCls;
@end

// Pure C API, adding to the existing API in objc/runtime.h.
// The functions above are implemented in terms of these.

//not used
const char *property_getTypeName(objc_property_t aProperty);

// returns a static buffer - copy the string to retain it, as it will
// be overwritten on the next call to this function
const char * property_getTypeString( objc_property_t aProperty );

// getter/setter functions: unlike those above, these will return NULL unless a getter/setter is EXPLICITLY defined
SEL property_getGetter( objc_property_t aProperty );
SEL property_getSetter( objc_property_t aProperty );

// this returns a static (data-segment) string, so the caller does not need to call free() on the result
const char * property_getRetentionMethod( objc_property_t aProperty );

